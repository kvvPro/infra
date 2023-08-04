lansible () 
{
docker run --rm \
            -w /opt \
            -v $(pwd):/opt/ \
            -v ~/.aws:/root/.aws \
            -v ~/.terraformrc:/root/.terraformrc \
            -v ~/.kube:/root/.kube \
            my/devops-tools ansible $@
}
laws () 
{
docker run --rm \
            -w /opt \
            -v $(pwd):/opt/ \
            -v ~/.aws:/root/.aws \
            -v ~/.terraformrc:/root/.terraformrc \
            -v ~/.kube:/root/.kube \
            my/devops-tools aws $@
}
lpacker () 
{
docker run --rm \
            -w /opt \
            -v $(pwd):/opt/ \
            -v ~/.aws:/root/.aws \
            -v ~/.terraformrc:/root/.terraformrc \
            -v ~/.kube:/root/.kube \
            my/devops-tools packer $@
}
lterraform () 
{
docker run --rm \
            -w /opt \
            -v $(pwd):/opt/ \
            -v ~/.aws:/root/.aws \
            -v ~/.terraformrc:/root/.terraformrc \
            -v ~/.kube:/root/.kube \
            my/devops-tools terraform $@
}
lkubectl () 
{
docker run --rm \
            -w /opt \
            -v $(pwd):/opt/ \
            -v ~/.aws:/root/.aws \
            -v ~/.terraformrc:/root/.terraformrc \
            -v ~/.kube:/root/.kube \
            my/devops-tools kubectl $@
}
lyc () 
{
docker run --rm \
            -w /opt \
            -v $(pwd):/opt/ \
            -v ~/.aws:/root/.aws \
            -v ~/.terraformrc:/root/.terraformrc \
            -v ~/.kube:/root/.kube \
            my/devops-tools yc $@
}