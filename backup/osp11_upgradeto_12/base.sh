if [ $# != 1 ] ; then
  echo "Usage: $0 <num>"
  echo "  num should 1 or 2"
  echo "  Provisioning Network should be provided as input!!"
  exit 1
fi

PROV=$1
if [[ $PROV != 1 && $PROV != 2 ]] ; then
  echo "Provisioning Network should be either 1 or 2 but $PROV given."
  exit 1
fi

ENV_FILE="network-environment-prov$PROV.yaml"
echo "Using provisioning environment file as $ENV_FILE ..."
