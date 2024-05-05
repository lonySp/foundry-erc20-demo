# Include .env file
-include .env

# Default private key for Anvil
DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

.PHONY: all test clean deploy fund help install snapshot format anvil 

# Help command to show usage
help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]"
	@echo "    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]"
	@echo "    example: make fund ARGS=\"--network sepolia\""

# Default build sequence
all: clean remove install update build

# Clean the repository
clean:
	forge clean

# Remove modules
remove:
	rm -rf .gitmodules .git/modules/* lib
	touch .gitmodules
	git add .
	git commit -m "Remove modules"

# Install dependencies
install:
	forge install Cyfrin/foundry-devops@0.0.11 --no-commit
	forge install foundry-rs/forge-std@v1.5.3 --no-commit
	forge install openzeppelin/openzeppelin-contracts@v4.8.3 --no-commit

# Update dependencies
update:
	forge update

# Build the project
build:
	forge build

# Run tests
test:
	forge test 

# Create a snapshot
snapshot:
	forge snapshot

# Format the code
format:
	forge fmt

# Start Anvil local blockchain
anvil:
	anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# Network arguments, modify for different environments
NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

# Conditionally modify network arguments if deploying to Sepolia
ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

# Deployment command
deploy:
	@forge script script/DeployOurToken.s.sol:DeployOurToken $(NETWORK_ARGS)

# Verification command, update with your details
verify:
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch \
	--constructor-args 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000 \
	--etherscan-api-key $(ETHERSCAN_API_KEY) --compiler-version v0.8.19+commit.7dd6d404 \
	0x089dc24123e0a27d44282a1ccc2fd815989e3300 src/OurToken.sol:OurToken
