<template>
  <div class="pagenation my-2">
    <span v-for="(pageNumber, index) in displayedPageNumbers" :key="index">
      <span
        class="page-number m-1 fs-5"
        v-bind:class="{ 'current-page': props.currentPage === pageNumber }"
        v-on:click="updatePageNumber(pageNumber, index)">
        {{ pageNumber }}
      </span>
    </span>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  array: Array,
  currentPage: Number,
  pageLimit: Number,
  displayRange: Number
})
const emit = defineEmits(['updateCurrentPage', 'increasePage', 'decreasePage'])

function updatePageNumber(pageNumber, index) {
  if (typeof pageNumber === 'number') {
    emit('updateCurrentPage', pageNumber)
    return
  }
  if (index < props.currentPage) {
    emit('decreasePage')
    return
  } else {
    emit('increasePage')
  }
}
const displayedPageNumbers = computed(() => {
  let pages = []
  const totalPages = Math.ceil(props.array.length / props.pageLimit)
  if (totalPages < 2) {
    return
  }
  pages.push(1)
  if (props.currentPage - props.displayRange > 2) {
    pages.push('...')
  }
  for (let i = -props.displayRange; i <= props.displayRange; i++) {
    if (
      props.currentPage + i > 1 &&
      props.currentPage + i < totalPages
    ) {
      pages.push(props.currentPage + i)
    }
  }
  if (props.currentPage + props.displayRange < totalPages - 1) {
    pages.push('...')
  }
  pages.push(totalPages)
  return pages
})
</script>

<style scoped>
.page-number {
  text-decoration: underline;
  cursor: pointer;
}
.current-page {
  font-weight: bold;
}
</style>
