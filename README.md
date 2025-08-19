Overview

This repository contains a Clarity smart contract that implements a Proof-of-Work (PoW) protocol on the Stacks blockchain.

The contract enables participants to submit computational work, have it verified on-chain, and receive STX rewards if the work is valid.

This project is designed for submission under Code for STX
.

Problem

Most blockchain PoW mechanisms are off-chain and energy-intensive, making them unsuitable for decentralized application layers like Stacks.
There is a need for a lightweight, on-chain verifiable PoW mechanism that can be used for:

Fair reward distribution

Randomness generation

Gamified applications and competitions

Solution

This PoW contract introduces a transparent, deterministic, and auditable on-chain protocol for work verification:

Challenge Issuance – A challenge (hash target) is defined by the contract.

Work Submission – Miners/participants submit a nonce and solution.

Verification – The contract checks if the submitted hash meets difficulty requirements.

Rewards – Valid solvers receive STX rewards from the reward pool.

Core Features

Challenge & Difficulty Setup – contract defines initial PoW conditions.

Solution Verification – ensures submitted work is valid against target hash.

Reward Distribution – successful solvers receive STX rewards.

Event Logging – every valid submission is logged for transparency.

Tech Stack

Smart Contract: Clarity

Testing: Clarinet
