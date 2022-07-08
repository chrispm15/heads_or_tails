# @version ^0.3.3

# Declare global variables
winner: public(bool)
active: public(bool)
guesses: public(uint256)
choice: uint256
owner: address

# Initialize variables and require 1 ETH for contract to be deployed
@external
@payable
def __init__():
    assert msg.value == (10**18)
    self.owner = msg.sender
    self.guesses = self.guesses
    self.active = True
    self.winner = False


# Function to pick heads or tails
@external
@payable
def play() -> uint256:
    # Check to make sure the contract has enough ETH to pay out in case of a win
    assert msg.value <= self.balance / 3, "Treasury is not large enough for your bet size. Please bet less."

    # Add to the running total of guesses
    self.guesses = self.guesses + 1

    # How the contract decides whether it will be heads or tails
    self.choice = uint256_mulmod(block.difficulty, block.number, 2)

    # Decision tree to decide whether or not the player won
    # Case 1: Fair loser, send contract creator 0.001 ETH
    if self.choice == 1:
        self.winner = False
        send(self.owner, 1000000)
        return self.choice

    #Case 2: Winner, check whether or not guesses is an even number to decide whether
    #.       the house will override and win.
    elif self.choice == 0:

        # Loser by house edge, pay contract creator 0.001 ETH
        if self.guesses % 2 == 0:
            self.winner = False
            self.choice = self.choice + 1
            send(self.owner, 1000000)
            return self.choice

        # Winner, pay player 2x their bet
        else:
            self.winner = True
            send(msg.sender, msg.value*2)
            return self.choice

    # If error, send bet back to player.
    else:
        send(msg.sender, msg.value)
        return self.choice

# Saftey net function for testing, allows contract creator to retrieve funds stuck in contract
@external
def emptyContract() -> String[100]:
    if msg.sender == self.owner:
        send(self.owner, self.balance)
        return "Success"
    else:
        return "Transaction failed. Function can only be called by contract creator."
