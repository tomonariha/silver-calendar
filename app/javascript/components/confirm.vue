<template>
  <div class="confirm">
    <p>{{ props.message }}</p>
    <button class="rounded m-1" v-on:click="emit('execution')">はい</button>
    <button class="rounded m-1" v-on:click="emit('cancel')">いいえ</button>
  </div>
</template>

<script setup>
const props = defineProps({
  message: String
})
const emit = defineEmits(['execution', 'cancel'])
</script>
