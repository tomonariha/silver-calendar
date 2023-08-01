<template>
  <div class="overlay" v-show="showConfirm" v-on:click.self="emit('cancel')">
    <div class="confirm">
      <p>{{ props.message }}</p>
      <button class="button-border m-1" v-on:click="emit('execution')">
        はい
      </button>
      <button class="button-border m-1" v-on:click="emit('cancel')">
        いいえ
      </button>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  message: String,
  showConfirm: Boolean
})
const emit = defineEmits(['execution', 'cancel'])
</script>

<style scoped>
.confirm {
  z-index: 3;
  max-width: 400px;
  padding: 2em;
  background: #fff;
}
</style>
