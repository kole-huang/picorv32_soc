/*
 * Modified from EmBox
 * @author Anton Bondarev
 */
#include <string.h>

#define FLAG_BUSY	0x1

struct mem_block_link {
	struct mem_block_link *prev;
	struct mem_block_link *next;
};

struct mem_block {
	struct mem_block_link link;
	struct mem_block *prev; // points to the previous adjacent mem block
	struct mem_block *next; // points to the next adjacent mem block
	unsigned long flags;
	size_t size;
};

static int heap_mm_ready;
static void *pool;
static unsigned long pool_size;
static struct mem_block_link free_mem_blocks = {&free_mem_blocks, &free_mem_blocks};
static struct mem_block_link busy_mem_blocks = {&busy_mem_blocks, &busy_mem_blocks};

static inline int block_is_busy(struct mem_block *block) {
	return (block->flags & FLAG_BUSY);
}

// insert block into the head of free_mem_blocks
static inline void block_link_free(struct mem_block *block) {
	block->link.next = free_mem_blocks.next;
	block->link.prev = &free_mem_blocks;
	free_mem_blocks.next->prev = &block->link;
	free_mem_blocks.next = &block->link;
}

// insert block into the head of busy_blocks
static inline void block_link_busy(struct mem_block *block) {
	block->link.next = busy_mem_blocks.next;
	block->link.prev = &busy_mem_blocks;
	busy_mem_blocks.next->prev = &block->link;
	busy_mem_blocks.next = &block->link;
}

// remove block from free_mem_blocks or busy_mem_blocks
static inline void block_unlink(struct mem_block *block) {
	block->link.next->prev = block->link.prev;
	block->link.prev->next = block->link.next;
}

static inline void mark_block_busy(struct mem_block *block) {
	block->flags |= FLAG_BUSY;
}

static struct mem_block * concatenate_prev(struct mem_block *block) {
	struct mem_block *pblock; /* prev block */

	while (block) {
		pblock = block->prev;

		if (!pblock || block_is_busy(pblock)) {
			break;
		}

		if (block->next)
			block->next->prev = pblock;
		pblock->next = block->next;
		pblock->size += block->size;

		// block is merged, remove it from free_mem_blocks list
		block_unlink(block);

		block = pblock;
	}

	return block;
}

static struct mem_block * concatenate_next(struct mem_block *block) {
	struct mem_block *nblock; /* next block */

	nblock = block->next;

	while (nblock) {
		if (!nblock || block_is_busy(nblock)) {
			break;
		}

		if (nblock->next)
			nblock->next->prev = block;
		block->next = nblock->next;
		block->size += nblock->size;

		// nblock is merged, remove it from free_mem_blocks list
		block_unlink(nblock);

		nblock = nblock->next;
	}

	return block;
}

static void split(struct mem_block *block, size_t size) {
	struct mem_block *nblock; /* new block */

	nblock = (struct mem_block *)((char *)block + sizeof(struct mem_block) + size);
	memset((void *)nblock, 0, sizeof(struct mem_block));
	nblock->next = block->next;
	nblock->prev = block;
	nblock->size = block->size - sizeof(struct mem_block) - size;
	nblock->flags = 0;
	block->size = sizeof(struct mem_block) + size;
	block->next = nblock;

	block_unlink(block); // remove block from free_mem_blocks list
	block_link_free(nblock); // add nblock into free_mem_blocks list
}

void *malloc(size_t size) {
	struct mem_block *block;
	struct mem_block_link *link;

	if (size <= 0) {
		return NULL;
	}

	size = (size + 3) & ~3;

	for (link = free_mem_blocks.next; link != &free_mem_blocks; link = link->next) {
		block = (struct mem_block *)link;
		if ((block->size - sizeof(struct mem_block)) >= (size + 32)) {
			split(block, size);
			mark_block_busy(block);
			block_link_busy(block); // add block into busy_mem_blocks list
			return (void *)((char *)(block) + sizeof(struct mem_block));
		} else if ((block->size - sizeof(struct mem_block)) >= size) {
			block_unlink(block); // remove block from free_mem_blocks list
			mark_block_busy(block);
			block_link_busy(block); // add block into busy_mem_blocks list
			return (void *)((char *)(block) + sizeof(struct mem_block));
		}
	}

	return NULL;
}

void free(void* ptr) {
	struct mem_block *block = (struct mem_block *)((char *)(ptr) - sizeof(struct mem_block));

	if (block_is_busy(block)) {
		block->flags = 0;
		block_unlink(block); // remove block from busy_mem_blocks list
		block_link_free(block); // insert block into free_mem_blocks list
		block = concatenate_prev(block);
		block = concatenate_next(block);
	}
}

void *calloc(size_t nmemb, size_t size) {
	void *tmp = malloc(nmemb * size);
	if (tmp) {
		memset(tmp, 0, nmemb * size);
	}
	return tmp;
}

void *realloc(void *ptr, size_t size) {
	char *tmp = malloc(size);
	if (tmp) {
		memcpy(tmp, ptr, size);
		free(ptr);
	}
	return tmp;
}

int malloc_init(unsigned long heap_start, unsigned long heap_size) {
	struct mem_block *block;

	if (heap_mm_ready)
		return 0;

	heap_start = (heap_start + 3) & ~3;
	heap_size = heap_size & ~3;

	if (heap_size < 1024)
		return 0;

	pool = (void *)heap_start;
	pool_size = heap_size;

	block = (struct mem_block *)pool;
	memset((void *)block, 0, sizeof(struct mem_block));
	block->size = heap_size;

	block_link_free(block);

	heap_mm_ready = 1;

	return 0;
}

