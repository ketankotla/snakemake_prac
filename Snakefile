rule all:
	input:
		"calls/all.vcf",
		"plots/quals.svg"

samples = ["A", "B", "C"]

rule bwa:
    input:
        "data/genome.fa",
        "data/samples/{sample}.fastq"
    output:
        "mapped_reads/{sample}.bam"
    conda: 
        "environment.yaml"
    shell:
        "bwa mem {input} | samtools view -Sb - > {output}"


rule sort:
	input:
		"mapped_reads/{sample}.bam",
	output:
		"mapped_reads/{sample}.sorted.bam",
	conda:
		"environment.yaml"
	shell:
		"samtools sort -o {output} {input}"

rule call:
	input:
		fa="data/genome.fa",
		bam=expand("mapped_reads/{sample}.sorted.bam", sample=samples)
	output:
		"calls/all.vcf"
	conda:
		"env5.yaml"
	shell:
		"samtools mpileup -g -f {input.fa} {input.bam} | bcftools call -mv - > {output}"

rule stats:
	input:
		"calls/all.vcf"
	output:
		"plots/quals.svg"
	conda:
		"env_stats.yaml"
	script:
		"scripts/plot-quals.py"