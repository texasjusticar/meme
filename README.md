# Meme

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'meme'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install meme

## Usage

### Autocomplete for meme

Add the following to your profile:
```
memecmds=(`ruby -r "{path to meme}/meme/lib/meme/generators.rb" -e "puts Meme::GENERATORS.keys"`)
compctl -k memecmds meme
```
## Contributing

1. Fork it ( https://github.com/[my-github-username]/meme/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
