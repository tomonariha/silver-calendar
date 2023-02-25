<template>
  <p>連携機能</p>{{authenticatedGoogle}}
  <p>Googleカレンダー</p>
  <button v-if="notAuthenticatedGoogle" v-on:click="redirectOAuth">Sign in with Google</button>
  <p v-else>認証済</p>
  <div v-for="calendar in calendars" :key="calendar.year">
    <div class="calendar_year__body">{{ calendar.year }}</div>
    <button v-bind:disabled="calendar.google_calendar_id" v-on:click="fetchGoogleCalendar(calendar, this.requestMethods['create'])">追加</button>
    <button v-bind:disabled="notExistsGoogleId(calendar.google_calendar_id)" v-on:click="fetchGoogleCalendar(calendar, this.requestMethods['delete'])">削除</button>
    <button v-bind:disabled="notExistsGoogleId(calendar.google_calendar_id)" v-on:click="fetchGoogleCalendar(calendar, this.requestMethods['update'])">更新</button>
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
      authenticatedGoogle: false,
      year: this.getCurrentYear(),
      requestMethods: { 
                        'create': 'POST',
                        'delete': 'DELETE',
                        'update': 'PUT'
                      }
    }
  },
  props: {
    calendars: { type: Array, required: true }
  },
  computed: {
    notAuthenticatedGoogle() {
      return !this.authenticatedGoogle
    },
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    fetchGoogleCalendar(calendar, method) {
      fetch(`api/calendars/${calendar.year}/alignment`, {
      method: method,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.token(),
      },
      credentials: 'same-origin'
      })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        if (method != 'delete') {
          calendar["google_calendar_id"] = json.google_calendar_id
        }
        this.$emit(method, calendar)
      })
      .catch((error) => {
        console.warn(error)
      })
    },
    getCurrentYear() {
      return new Date().getFullYear()
    },
    notExistsGoogleId(google_calendar_id) {
      return !google_calendar_id
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
        this.authenticatedGoogle = json.authenticate
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
    this.fetchUser()
  },
  emits: ['close', 'delete', 'create', 'update']
})
</script>
