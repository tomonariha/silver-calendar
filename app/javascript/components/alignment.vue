<template>
  <p>連携機能</p>
  <p>Googleカレンダー</p>
  <div v-for="calendar in calendars" :key="calendar.year">
    <div class="calendar_year__body">{{ calendar.year }}</div>
    <button v-bind:disabled="calendar.google_calendar_id" v-on:click="fetchGoogleCalendar(calendar.year, this.requestMethods['create'])">追加</button>
    <button v-bind:disabled="notExistsGoogleId(calendar.google_calendar_id)" v-on:click="fetchGoogleCalendar(calendar.year, this.requestMethods['delete'])">削除</button>
    <button v-bind:disabled="notExistsGoogleId(calendar.google_calendar_id)" v-on:click="fetchGoogleCalendar(calendar.year, this.requestMethods['update'])">更新</button>
  </div>
  <br>
  <button v-on:click="$emit('close')">閉じる</button>
</template>

<script lang="ts">
import { defineComponent } from 'vue'

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
    notExistsGoogleId(google_calendar_id) {
      return !google_calendar_id
    },
  },
  mounted() {
    this.fetchCalendars()
  },
  emits: ['close']
})
</script>
