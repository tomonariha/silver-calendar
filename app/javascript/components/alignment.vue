<template>
  <p>連携機能</p>
  <p>googleカレンダー</p>
  <div v-for="calendar in calendars" :key="calendar.year">
    <Popper arrow>
      <button class="calendar_year__body">{{ calendar.year }}</button>
      <template #content>
        <button v-on:click="fetchGoogleCalendar(calendar.year, this.requestMethods['create'])">Googleカレンダーにカレンダーを追加する</button>
        <br>
        <button v-on:click="fetchGoogleCalendar(calendar.year, this.requestMethods['delete'])">Googleカレンダーとの連携を解除する</button>
        <br>
        <button v-on:click="fetchGoogleCalendar(calendar.year, this.requestMethods['update'])">Googleカレンダーを更新する</button>
      </template> 
    </Popper>
  </div>
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
      calendars: [],
      requestMethods: { 
                        'create': 'POST',
                        'delete': 'DELETE',
                        'update': 'PUT'
                      }
    }
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    fetchGoogleCalendar(year, method) {
      fetch(`api/calendars/${year}/alignment`, {
      method: method,
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
