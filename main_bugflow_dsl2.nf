#!/usr/bin/env nextflow

/* 
DSL2 version of Bugflow: A pipeline for mapping followed by variant calling and de novo assembly of Illumina short read libraries

QC
 - Fastp
 - FastQC
 - MultiQC
 - Quast

Mapping and Variant calling
 - snippy
 
Assembly
 - shovill (spades) 
*/

// enable DSL2
nextflow.enable.dsl = 2

/*
#==============================================
Modules
#==============================================
*/

include { RAWFASTQC; FASTP; CLEANFASTQC; MULTIQC  } from './modules/processes-bugflow_dsl2.nf'
include { ASSEMBLY } from './modules/processes-bugflow_dsl2.nf'
include { QUAST } from './modules/processes-bugflow_dsl2.nf'
include { SNIPPYFASTQ } from './modules/processes-bugflow_dsl2.nf'
include { SNIPPYFASTA } from './modules/processes-bugflow_dsl2.nf' 
include { SNIPPYCORE } from './modules/processes-bugflow_dsl2.nf'

/*
#==============================================
Parameters
#==============================================
*/

params.ref = " "
params.reads = " "
params.outdir = " "
params.contigs = " "

/*
#==============================================
Channels
#==============================================
*/

//Channel.fromFilePairs(params.reads, checkIfExists: true)
       //.map{it}
       //.view()
       //.set{reads}

//Channel.fromPath(params.ref, checkIfExists:true)
        //.view()       
       //.set{refFasta}

//Channel.fromPath(params.contigs, checkIfExists:true)
       //.set{assembly}
       //.view()

//return

/*
#==============================================
Workflows
#==============================================
*/

workflow shovill {
    Channel.fromFilePairs(params.reads, checkIfExists: true)
           .map{it}
           //.view()
           .set{reads}
    
    main:
    RAWFASTQC(reads)
    FASTP(reads)
    CLEANFASTQC(FASTP.out.reads)
    MULTIQC(RAWFASTQC.out.mix(CLEANFASTQC.out).collect())
    ASSEMBLY(FASTP.out.reads)
    QUAST(ASSEMBLY.out)
    MULTIQC(QUAST.out.collect())
}

//return

workflow qc_contigs {
    Channel.fromPath(params.contigs, checkIfExists:true)
           //.view()
           .set{assembly}
    main:       
    QUAST(assembly)
    MULTIQC(QUAST.out.collect())
}

workflow snippy_fastq {
    Channel.fromFilePairs(params.reads, checkIfExists: true)
           .map{it}
           //.view()
           .set{reads}
    
    Channel.fromPath(params.ref, checkIfExists:true)
           //.view()       
           .set{refFasta}
    
    main:
    FASTP(reads)
    SNIPPYFASTQ(FASTP.out.reads[0].mix(reads[1]).collect(), refFasta)
    //SNIPPYFASTQ(reads.collect(), refFasta)
    //emit:
    //SNIPPYFASTQ.out // results
}       

workflow snippy_fasta {
    Channel.fromPath(params.contigs, checkIfExists:true)
           //.view()
           .set{assembly}

    Channel.fromPath(params.ref, checkIfExists:true)
           //.view()       
           .set{refFasta}

    main:
    SNIPPYFASTA(assembly, refFasta)
    
    emit:
    SNIPPYFASTA.out // results
}  


//return

workflow  snippy_core {
    FASTP(reads)
    SNIPPYFASTQ(FASTP.out.reads, refFasta)
    SNIPPYCORE(SNIPPYFASTQ.out.collect(), refFasta)        
}


