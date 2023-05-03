<template>
  <div class="confirm">
    <p>削除します。よろしいですか？</p>
    <button class="rounded m-1" v-on:click="emit('delete')">はい</button>
    <button class="rounded m-1" v-on:click="emit('cancel')">いいえ</button>
  </div>
</template>

<script setup>
const emit = defineEmits(['cancel', 'delete'])
</script>
