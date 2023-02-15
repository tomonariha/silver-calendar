<template>
  <p>連携機能</p>
  <p>googleカレンダー</p>
  <div v-for="calendar in calendars" :key="calendar.year">
    <Popper arrow>
      <button class="calendar_year__body">{{ calendar.year }}</button>
      <template #content>
        <button v-on:click='insertGoogleCalendar(calendar.year)'>Googleカレンダーにカレンダーを追加する</button>
      </template> 
    </Popper>
  </div>
  <br>
  <p>連携済みのカレンダー</p>
  <button v-on:click='deleteGoogleCalendar'>Googleカレンダーとの連携を解除する</button>
  <br>
  <button v-on:click="$emit('close')">閉じる</button>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import Popper from 'vue3-popper'

export default defineComponent({
  name: 'alignment',
  data() {
    return {
      year: this.getCurrentYear(),
      calendars: []
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    insertGoogleCalendar(year) {
      fetch(`api/calendars/${year}/alignment`, {
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
    },
    deleteGoogleCalendar() {
      fetch(`api/calendars/${this.year}/alignment/${this.calendar_id}`, {
      method: 'DELETE',
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
    },
    getCurrentYear() {
      return new Date().getFullYear()
    },
    fetchCalendars() {
      fetch('api/calendars', {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token()
      },
      credentials: 'same-origin'
      })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        json.forEach((r) => {
          this.calendars.push(r)
        })
      })
      .catch((error) => {
        console.warn(error)
      })
    },
  },
  mounted() {
    this.fetchCalendars()
  },
  components: {
    Popper,
  },
  emits: ['close']
})
</script>
