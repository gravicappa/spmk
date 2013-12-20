%:Q:
  if (~ $target *' '*)
    exit
  _found=0
  for (_x in /var/log/packages/$target-[0-9]*)
    if (test -e $_x)
      _found=1
  if (~ $_found 0)
    {$sudo slapt-get -i $target || $sudo slapt-src -i $target} </dev/tty
  if not true
