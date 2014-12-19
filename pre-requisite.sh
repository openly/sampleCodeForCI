applications=(
  'node'
  'coffee'
  'forever'
  'asdf'
)
exitVal=0
for app in ${applications[@]}
do
  command -v $app >/dev/null 2>&1 || {
    echo "$app is not installed." >&2;
    exitVal=1;
  }
done
exit $exitVal;