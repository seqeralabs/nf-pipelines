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

include { INITIALISE                    } from './subworkflows/nf-core/initialise/'
include { GATK4_MARKDUPLICATES          } from './modules/nf-core/gatk4/markduplicates/main'
include { GATK4_EXTRACTFINGERPRINT      } from './modules/local/gatk4/extractfingerprint/main'
include { PICARD_CROSSCHECKFINGERPRINTS } from './modules/nf-core/picard/crosscheckfingerprints/main'
include { MULTIQC                       } from './modules/nf-core/multiqc/'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NFPIPELINE {

    ch_versions   = Channel.empty()
    ch_multiqc    = Channel.empty()

    haplotype_map = Channel.fromPath(params.haplotype_map   , checkIfExists: true).collect()
    fasta         = Channel.fromPath(params.fasta           , checkIfExists: true).collect()
    dict          = Channel.fromPath(params.dict            , checkIfExists: true).collect()
    fai           = params.fai ? Channel.fromPath(params.fai, checkIfExists: true).collect() : Channel.fromPath("${file(params.fasta).toUriString()}.fai", checkIfExists: true).collect()
    INITIALISE(
        params.version,
        params.help,
        params.validateParams,
        params.logo
    )

    // See the documentation https://nextflow-io.github.io/nf-validation/samplesheets/fromSamplesheet/
    Channel
        .fromSamplesheet('input')
        .map { meta, bam -> [meta, bam, file("${bam.toUriString()}.bai")]}
        .set { ch_input }

    GATK4_MARKDUPLICATES(
        ch_input,
        fasta,
        fai
    )
    ch_versions = ch_versions.mix(GATK4_MARKDUPLICATES.out.versions)
    ch_multiqc  = ch_multiqc.mix(GATK4_MARKDUPLICATES.out.metrics)

    dedup_bams = GATK4_MARKDUPLICATES.out.bam.join(GATK4_MARKDUPLICATES.out.bai)

    GATK4_EXTRACTFINGERPRINT(
        dedup_bams,
        haplotype_map,
        fasta,
        fai,
        dict
    )
    ch_versions = ch_versions.mix(GATK4_EXTRACTFINGERPRINT.out.versions)
    ch_multiqc  = ch_multiqc.mix(GATK4_EXTRACTFINGERPRINT.out.vcf)

    vcf_ch = GATK4_EXTRACTFINGERPRINT.out.vcf.map { meta, vcf -> [[id: "picard"], vcf] }
    tbi_ch = GATK4_EXTRACTFINGERPRINT.out.tbi.map { meta, tbi -> [[id: "picard"], tbi] }

    vcf_ch.join(tbi_ch)
        .groupTuple()
        .set { crosscheck_input}
    
    PICARD_CROSSCHECKFINGERPRINTS(
        crosscheck_input,
        [[:], [], []],
        haplotype_map
    )
    ch_versions = ch_versions.mix(PICARD_CROSSCHECKFINGERPRINTS.out.versions)
    ch_multiqc  = ch_multiqc.mix(PICARD_CROSSCHECKFINGERPRINTS.out.crosscheck_metrics)

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
