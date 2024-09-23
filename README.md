# MGPipe
## _MetaGenomics Pipeline_

This shotgun metagenomics pipeline processes raw Illumina paired-end reads into usable microbiome data, suitable for phyloseq postprocessing in R.

### Instructions:

To use MGPipe, you need to have conda installed, Kraken2/Bracken databases downloaded, and HUMAnN3 installed. 

#### 1) Install conda:
`mkdir ./bin` <br>
`wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./bin/miniconda.sh` <br>
When prompted, enter: <br>
`./bin/miniconda3` as your installation path and say yes to everything when prompted.

#### 2) Download Kraken2/Bracken databases:
Kraken2/Bracken updates its standard reference database. <br>
To download the most recent database, please reference https://benlangmead.github.io/aws-indexes/k2. <br>
This command was run to download the most recent database:
`curl --header 'Host: genome-idx.s3.amazonaws.com' --header 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header 'Accept-Language: en-US,en;q=0.9' --header 'Referer: https://benlangmead.github.io/' 'https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20240605.tar.gz' -L -o 'k2_standard_20240605.tar.gz'`

#### 3) Install HUMAnN3:
HUMAnN is updated every so often. <br>
Reference https://github.com/biobakery/humann for installation. <br>
Download the latest tarball via: <br>
`curl --header 'Host: files.pythonhosted.org' --header 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header 'Accept-Language: en-US,en;q=0.9' --header 'Referer: https://pypi.org/' 'https://files.pythonhosted.org/packages/b2/8f/0d908a2a43f89f03e4d1f22baf80b77a4bce342b721552737173c4da74cd/humann-3.9.tar.gz' -L -o 'humann-3.9.tar.gz'`
