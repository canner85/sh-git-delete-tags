# sh-git-delete-tags

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg?style=flat-square)](http://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/canner85/sh-git-delete-tags.svg?style=flat-square)](https://github.com/canner85/sh-git-delete-tags/releases)

Shell script to delete local and remote git tags, prompts before deleting. Build on Mac OS 10.12.

## Usage

1. Copy the [script](delete-tags.sh) to your desired directory (lets say to your root folder `~`. 
2. Make it executable `chmod +x ~/delete-tags.sh`.
3. Create an alias for global usage `alias git.deleteTags='~/delete-tags.sh'`
4. `cd` into your repo folder
5. Execute `git.deleteTags <tagNames> [-v|--verbose] [-r|--remote]`
	1. `tagNames` represents a string to search for in your tag list
	2. `-v|--verbose` is used to revert the search (exclude)
	3. `-r|--remote` is used to delete remote tags
	4. `-il|--ignore-local` is used to ignore local tags
	5. `-h|--help` show usage

## Examples

- `git.deleteTag v1.0`
	- search for local tag names including "v1.0"
- `git.deleteTag v1.0 -r`
	- search for local and remote tag names including "v1.0"
- `git.deleteTag v1.0 -r -il`
	- search for remote tag names including "v1.0"
- `git.deleteTag v1.0 -v`
	- search for local tag names except "v1.0"

## License

This work is licensed under the [The MIT License](LICENSE).
