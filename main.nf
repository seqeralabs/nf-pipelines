#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { FASTP } from './modules/nf-core/fastp/main'

workflow {
    input = Channel.of([[ id:'test', single_end:false ], // meta map
            [ file("https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fastq/test_1.fastq.gz", checkIfExists: true),
            file("https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fastq/test_2.fastq.gz", checkIfExists: true) ]]
    )
    input.view()
    FASTP(input, [], false, false)
}
