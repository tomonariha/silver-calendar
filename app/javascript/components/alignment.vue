<template>
  <p>連携機能</p>
  <p>Googleカレンダー</p>{{user}}
  <button v-if="notAlignedGoogle(user)" v-on:click="redirectOAuth">Sign in with Google</button>
  <div v-else>認証済</div>
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
      user: {},
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
    notAlignedGoogle(user) {
      return !user.uid && !user.provider
    },
    fetchUser() {
      fetch('api/users', {
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
        this.user = json.user
      })
      .catch((error) => {
        console.warn(error)
      })
    },
    redirectOAuth() {
      window.location.href = '/users/auth/google_oauth2'
    }
  },
  mounted() {
    this.fetchCalendars()
    this.fetchUser()
  },
  emits: ['close']
})
</script>
