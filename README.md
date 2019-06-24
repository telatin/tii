# tii
**a command line tool like *tee* but also saving to the Internet (PasteBin)**

### PasteBin.com API key

To use this script you'll need an API key from [PasteBin.com](https://pastebin.com/), the amazing online service behind this script.

Register for and account and then you can obtain your API from [this page](https://pastebin.com/api).

You can save your API key in `~/.pastebin` to avoid supplying it to the script. Just put the API key without any other data, for example with this command: `echo 'API_KEY' > ~/.pastebin`.

### Usage

```
cat  your-files | tii [filename]
```

The proram will print at the end the URL of your new pastebin. Note: to work as expected (like _tee_) the URL will be printed in the STDERR strem, unless you specify `--silent`.

### Program options

```
  cat file.txt | tii [options] [filename]
  --------------------------------------------------------------------------
  Like tee, but will create a pastebin.com entry with your text.

  Options:
    -a, --append          Append to filename rather than overwriting

    -s, --silent          Will not print the stream to STDOUT

    -k, --apikey          Pastebin.com api key.
                          Can be stored (alone) in the ~/.pastebin file

    -t, --title           Pastebin title [default: $opt_title]

    -f, --format          Syntax highlight like: perl, php, javascript, python..

    -e, --expiry          Default N (never). Alternatives: 10M (10 minutes), 
                          1H (1 hour), 1D (1 day), 1W (1 week), 1M (1 month), 
                          6M (6 months),1Y (1 year)

    -l, --listed          Make the pasted listed [default: publica but unlisted]

    -p, --private         Make the pasted text private [overrides -l]

```

### Dependencies
This is a perl script that uses a local copy of [WWW::Pastebin::PastebinCom::API](https://metacpan.org/pod/WWW::Pastebin::PastebinCom::API).
A CPAN version with dependency management is under development.

