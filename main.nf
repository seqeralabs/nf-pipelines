#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-pipelines
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

nextflow.enable.dsl = 2


include { validateParameters; paramsSummaryLog; fromSamplesheet } from 'plugin/nf-validation'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES AND SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MULTIQC    } from './modules/nf-core/multiqc/'
include { INITIALISE } from './subworkflows/nf-core/initialise/'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NFPIPELINE {

    ch_versions = Channel.empty()
    ch_multiqc  = Channel.empty()

    INITIALISE(
        params.version,
        params.help,
        params.validateParams,
        params.logo
    )

    // See the documentation https://nextflow-io.github.io/nf-validation/samplesheets/fromSamplesheet/
    Channel
        .fromSamplesheet('input')
        // Coerces from [ meta, fastq1, fastq2 ] to [ meta, [ fastq1, fastq2 ] ]. Required for nf-core modules.
        // See https://github.com/nextflow-io/nf-validation/issues/81
        .map { meta, fastq1, fastq2 -> fastq2 ? tuple(meta, [fastq1, fastq2]) : tuple(meta, [fastq1]) }
        .set { ch_input }

    // Run tool or subworkflow here:
    // TOOL(ch_input, ch_genome)
    // Add to MultiQC channel:
    // ch_multiqc  = ch_multiqc.mix(TOOL.out.lint)

    MULTIQC(
        ch_multiqc.collect{ it[1] },
        [],
        [], 
        []
    )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow {
    NFPIPELINE ()
}
