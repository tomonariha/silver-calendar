<template>
  <p>連携機能</p>
  <p>googleカレンダー</p>
  <button v-on:click='reflectGoogleCalendar'>Googleカレンダーにこのカレンダーを反映する</button>
  <br>
  <button v-on:click="$emit('close')">閉じる</button>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
export default defineComponent({
  name: 'alignment',
  data() {
    return {
      year: 2023
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    reflectGoogleCalendar() {
      fetch(`api/alignments/${this.year}`, {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token(),
      },
      credentials: 'same-origin'
      })
      .then(() => {
        
      })
      .catch((error) => {
        console.warn(error)
      })
    }
  },
  emits: ['close']
})
</script>
