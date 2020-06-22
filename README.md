# bracken-nf

Map metagenomic reads to operational taxonomic units (OTUs) using [kraken2](https://github.com/DerrickWood/kraken2) and estimate bacterial abundances with [bracken](https://github.com/jenniferlu717/Bracken).

## Usage

1. Set up nextflow as [described
   here](https://www.nextflow.io/index.html#GetStarted).
2. If you didn't run this pipeline in a while, possibly update nextflow itself.
    ```
    ./nextflow self-update
    ```
3. Then run the pipeline.
    ```
    ./nextflow run https://github.com/UnseenBio/bracken-nf
    ```

## Copyright

-   Copyright © 2020, Unseen Biometrics ApS.
-   Free software distributed under the [GNU Affero General Public License version 3](https://opensource.org/licenses/AGPL-3.0).
