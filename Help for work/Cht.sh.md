#bash #help #linux
### Installation

[](https://github.com/chubin/cheat.sh?tab=readme-ov-file#installation)

1. To install the client:
```shell
PATH_DIR="$HOME/bin"  # or another directory on your $PATH
mkdir -p "$PATH_DIR"
curl https://cht.sh/:cht.sh > "$PATH_DIR/cht.sh"
chmod +x "$PATH_DIR/cht.sh"
```

2. or to install it globally (for all users):
```shell
curl -s https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh
```

Note: The package "rlwrap" is a required dependency to run in shell mode. Install this using `sudo apt install rlwrap`