# Declare this file as a StarkNet contract.
%lang starknet

from contracts.account.AddressRegistry import get_L1_address, set_L1_address
from contracts.utils.constants import L1_CONTRACT_ADDRESS

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address
from starkware.starknet.common.messages import send_message_to_l1


############
# External #
############

# Register new user with L1 credentials
@external
func register_user{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(l1_address : felt) -> ():

    let (caller_address) = get_caller_address()
    # validate is new user
    let (caller_l1_address) = get_L1_address(caller_address)

    assert caller_l1_address = 0

    set_L1_address(l1_address)

    return ()
end


# List
@external
func list_erc721{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(l1_address : felt) -> ():

    let (caller_address) = get_caller_address()
    let (caller_l1_address) = get_L1_address(caller_address)

    # validate user is already registered
    assert_not_zero(caller_l1_address)

    # Create a dynamically sized array for the message.
    let (message : felt*) = alloc()

    # _tokenContract: The address of the ERC-721 token to be sold
    assert message[0] = 0

    # _tokenId: The ID of the ERC-721 token to be sold
    assert message[1] = 0

    # _askPrice: The price to fill the ask
    assert message[2] = 0

    # _askCurrency: The address of the ERC-20 token required to fill, or address(0) for ETH
    assert message[3] = 0

    # _sellerFundsRecipient: The address to send funds once the ask is filled
    assert message[4] = 0

    # _findersFeeBps: The bps of the ask price (post-royalties) to be sent to the referrer of the sale
    assert message[5] = 0

    # Send the message.
    send_message_to_l1(
        to_address=L1_CONTRACT_ADDRESS,
        payload_size=3,
        payload=message)

    return ()
end


# Buy
@external
func buy_erc721{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(l1_address : felt, l1_public_key : felt, l1_address_signature : felt) -> ():

    let (caller_address) = get_caller_address()
    let (caller_l1_address) = get_L1_address(caller_address)

    # validate user is already registered
    assert_not_zero(caller_l1_address)

    # Create a dynamically sized array for the message.
    let (message : felt*) = alloc()

    # _tokenContract: The address of the ERC-721 token to be sold
    assert message[0] = 0

    # _tokenId: The ID of the ERC-721 token to be sold
    assert message[1] = 0

    # _fillCurrency: The address of the ERC-20 token using to fill, or address(0) for ETH
    assert message[2] = 0

    # _fillAmount: The amount to fill the ask
    assert message[3] = 0

    # _finder: The address of the ask referrer
    assert message[4] = 0

    # Send the message.
    send_message_to_l1(
        to_address=L1_CONTRACT_ADDRESS,
        payload_size=3,
        payload=message)

    return ()
end

    