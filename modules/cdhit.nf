/************************************************************************
* CD-HIT-EST
*
* Cluster sequences by similarity
************************************************************************/

process cdhit {
  label 'cdhit'
  publishDir "${params.output}/${params.cdhit_output}", mode: 'copy', pattern: '*_cdhitest.fasta*'
  publishDir "${params.output}/${params.cdhit_output}", mode: 'copy', pattern: '*UNCLUSTERED*'
  publishDir "${params.output}/${params.summary_output}/unclustered_sequences", mode: 'copy', pattern: '*UNCLUSTERED.fasta'
  publishDir "${params.output}/${params.summary_output}/clustered_sequences", mode: 'copy', pattern: '*_cdhitest.fasta'

  input:
    path(sequences)
    val(addParams)

  output:
    tuple val("${params.output}/${params.cdhit_output}"), path ("${sequences.baseName}_cdhitest.fasta"), emit: cdhit_result
    path "${sequences.baseName}_cdhitest.fasta.clstr", emit: cdhit_cluster
    path "${sequences.baseName}_cdhitest_UNCLUSTERED.fasta"

  script:
  """
    cd-hit-est ${addParams} -i ${sequences} -o "${sequences.baseName}_cdhitest.fasta"
    python3 ${baseDir}/bin/cdhit2goodcdhit.py "${sequences.baseName}_cdhitest.fasta.clstr" ${sequences} > tmp.clstr
    mv tmp.clstr "${sequences.baseName}_cdhitest.fasta.clstr"
    python3 ${projectDir}/bin/filter_unclustered.py "${sequences.baseName}_cdhitest.fasta" "${sequences.baseName}_cdhitest.fasta.clstr"
  """
}


process remove_redundancy {
  label 'remove'
  publishDir "${params.output}/${params.nr_output}", mode: 'copy', pattern: "*_nr.fasta"

  input:
    path(sequences)

  output:
    path "${sequences.baseName}_nr.fasta", emit: nr_result
    path "${sequences.baseName}_nr.error.log"

  script:
  """
    cd-hit-est -M 4000 -c 1 -i ${sequences} -o "${sequences.baseName}_nr.fasta"  2>"${sequences.baseName}_nr.error.log"
    sed -E "/>/ s/[:,()' ;]/_/g" "${sequences.baseName}_nr.fasta" > ${sequences.baseName}_renamed.fasta
    mv ${sequences.baseName}_renamed.fasta ${sequences.baseName}_nr.fasta
  """
}