#!/usr/bin/env nextflow

nextflow.preview.dsl=2

include abundance from './abundance'

/* ############################################################################
 * Default parameter values.
 * ############################################################################
 */

params.database_path = 'databases'
params.database = 'Standard_v2'
params.read_length = 100
params.threshold = 10
params.sequences = 'sequences'
params.outdir = 'results'

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
FASTQ Path: ${params.sequences}
Results Path: ${params.outdir}
Kraken Database Path: ${params.database_path}
Selected Kraken Database: ${params.database}
Read length: ${params.read_length}
Bracken threshold: ${params.threshold}
************************************************************

"""

  databases = Channel.fromPath("${params.database_path}",
    type: 'dir',
    checkIfExists: true
  )

  fastq_triples = Channel.fromFilePairs("${params.sequences}/**{1,2}.fastq.gz",
    checkIfExists: true,
    flat: true
  )

  levels = Channel.of('F', 'G', 'S')

  abundance(databases, fastq_triples, levels)
}
