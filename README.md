This README provides an overview of the Cache Controller design based on the specifications for a direct-mapped, write-back system.

---

# Simple Cache Controller (16 KB)

This project implements a Finite-State Machine (FSM) based controller for a 16 KB direct-mapped cache. The design manages requests between a 32-bit processor interface and a 128-bit memory interface.

## Cache Specifications

The cache is designed with the following architectural parameters:
*   **Type:** Direct-Mapped
*   **Capacity:** 16 KB (1024 blocks)
*   **Block Size:** 16 bytes (128 bits / 4 words)
*   **Write Policy:** Write-back with Write-allocate
*   **Address Width:** 32-bit
*   **Metadata:** Valid bit and Dirty bit per block

### Address Breakdown
The 32-bit address is partitioned as follows:
*   **Tag:** 18 bits (used to verify the correct data block)
*   **Index:** 10 bits (used to select one of the 1024 blocks)
*   **Block Offset:** 4 bits (used to select the byte within the block)

## System Interfaces

### Processor Interface
Communication with the CPU is blocking; the processor waits for a "Ready" signal before continuing.
*   **Control:** Read/Write signal, Valid signal.
*   **Data:** 32-bit address, 32-bit input data, 32-bit output data.
*   **Status:** Ready signal (high when the operation is complete).

### Memory Interface
The interface to the main memory utilizes a wider data bus to match the cache block size.
*   **Control:** Read/Write signal, Valid signal.
*   **Data:** 32-bit address, 128-bit data from cache, 128-bit data from memory.
*   **Status:** Ready signal (asynchronous completion notification).

## Controller Logic (FSM)
The cache is governed by a Finite-State Machine that handles the following scenarios:
1.  **Read Hit:** Data is returned to the processor immediately.
2.  **Write Hit:** Data is updated in the cache and the dirty bit is set.
3.  **Read/Write Miss (Clean):** The required block is fetched from memory.
4.  **Read/Write Miss (Dirty):** The existing dirty block is written back to memory before the new block is fetched.


<img width="498" height="436" alt="image" src="https://github.com/user-attachments/assets/163e7dde-cb4e-4f53-a245-975d4bdc5a5f" />

<sub>Source: [Patterson & Hennessy, Figure 5.7](https://example.com/link)</sub>


---
