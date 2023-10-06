#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { FASTP } from './modules/nf-core/fastp/main'

params.fastq_1 = "https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fastq/test_1.fastq.gz"
params.fastq_2 = "https://raw.githubusercontent.com/nf-core/test-datasets/modules/data/genomics/sarscov2/illumina/fastq/test_2.fastq.gz"

input = Channel.of([[ id:'test' ], [ file(params.fastq_1, checkIfExists: true), file(params.fastq_2, checkIfExists: true) ]])

workflow {
    FASTP(input, [], false, false)
}
