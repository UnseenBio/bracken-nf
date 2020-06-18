#!/usr/bin/env nextflow

nextflow.preview.dsl=2

/* ############################################################################
 * Default parameter values.
 * ############################################################################
 */

params.database_path = 'databases'
params.database = 'Standard_v2'
params.read_length = 100
params.input = 'sequences'
params.outdir = 'results'

/* ############################################################################
 * Define workflow processes.
 * ############################################################################
 */

process kraken {
  publishDir "${params.outdir}", mode:'link'

  input:
  tuple path(databases), val(sample), path(first_fastq), path(second_fastq)

  output:
  path "${sample}_classified_{1,2}.fastq", emit: classified_sequences
  path "${sample}_unclassified_{1,2}.fastq", emit: unclassified_sequences
  path "${sample}.k2", emit: data
  path "${sample}.k2report", emit: report

  """
  kraken2 \
    --db "${databases.resolve(params.database)}" \
    --threads ${task.cpus} \
    --classified "${sample}_classified#.fastq" \
    --unclassified "${sample}_unclassified#.fastq" \
    --output "${sample}.k2" \
    --report "${sample}.k2report" \
    --report-zero-counts \
    --paired \
    --use-names \
    --gzip-compressed \
    "${first_fastq}" "${second_fastq}"
  """
}

process bracken {
  publishDir "${params.outdir}", mode:'link'

  input:
  tuple path(databases), path(kraken_report), val(taxonomy_level)

  output:
  path "${kraken_report.getSimpleName()}_${taxonomy_level}.bracken", emit: report

  """
  bracken \
    -d "${databases.resolve(params.database)}" \
    -i "${kraken_report}" \
    -o "${kraken_report.getSimpleName()}_${taxonomy_level}.bracken" \
    -r ${params.read_length} \
    -l ${taxonomy_level}
  """
}

/* ############################################################################
 * Define named workflows to be included elsewhere.
 * ############################################################################
 */

 workflow abundance {
  take:
  databases
  fastq_triples
  taxonomy_level

  main:
  kraken(databases.combine(fastq_triples))
  bracken(databases.combine(kraken.out.report).combine(taxonomy_level))

  emit:
  bracken.out.report
 }

/* ############################################################################
 * Define an implicit workflow that only runs when this is the main nextflow
 * pipeline called.
 * ############################################################################
 */

workflow {
  log.info """
************************************************************

kraken2 & bracken abundance estimation
======================================
FASTQ Path: ${params.input}
Results Path: ${params.outdir}

************************************************************

"""

  databases = Channel.fromPath("${params.database_path}",
    type: 'dir',
    checkIfExists: true
  )

  fastq_triples = Channel.fromFilePairs("${params.input}/**{1,2}.fastq.gz",
    checkIfExists: true,
    flat: true
  )

  levels = Channel.of('F', 'G', 'S')

  abundance(databases, fastq_triples, levels)
}
