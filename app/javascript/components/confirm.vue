<template>
  <div>削除します。よろしいですか？</div>
  <button v-on:click="emit('delete')">はい</button>
  <button v-on:click="emit('cancel')">いいえ</button>
</template>

<script setup>
const emit = defineEmits(['cancel', 'delete'])
</script>
