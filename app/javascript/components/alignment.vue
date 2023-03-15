<template>
  <p>連携機能</p>
  <p>Googleカレンダー</p>
  <button v-if="notAuthenticatedGoogle" v-on:click="redirectOAuth">Sign in with Google</button>
  <p v-else>認証済</p>
  <div v-for="calendar in slicedCalendars" :key="calendar.year">
    <div class="calendar_year__body">{{ calendar.year }}</div>
    <button v-bind:disabled="calendar.google_calendar_id" v-on:click="fetchGoogleCalendar(calendar, requestMethods['create'])">追加</button>
    <button v-bind:disabled="notExistsGoogleId(calendar.google_calendar_id)" v-on:click="fetchGoogleCalendar(calendar, requestMethods['delete'])">削除</button>
    <button v-bind:disabled="notExistsGoogleId(calendar.google_calendar_id)" v-on:click="fetchGoogleCalendar(calendar, requestMethods['update'])">更新</button>
  </div>
  <div v-for="pageNumber in totalPages" :key="pageNumber">
    <button v-on:click="updatePageNumber(pageNumber)">{{ pageNumber }}</button>
  </div>
  <br>
  <button v-on:click="emit('close')">閉じる</button>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
const authenticatedGoogle = ref(false)
const requestMethods = { 
                        'create': 'POST',
                        'delete': 'DELETE',
                        'update': 'PUT'
                      }
const currentPage = ref(1)
const pageLimit = ref(5)
const props = defineProps({
    calendars: Array
  })
  //computed
const notAuthenticatedGoogle = computed(() => {
      return !authenticatedGoogle.value
    })
const slicedCalendars = computed(() => {
      let start = (currentPage.value -1) * pageLimit.value
      let end = start + pageLimit.value
      return props.calendars.slice(start, end)
    })
const totalPages = computed(() => {
      return Math.ceil(props.calendars.length / pageLimit.value)
    })
  //ここまでcomp
function updatePageNumber(pageNumber) {
  currentPage.value = pageNumber
}
  function token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    }
  function fetchGoogleCalendar(calendar, method) {
      fetch(`api/calendars/${calendar.year}/alignment`, {
      method: method,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': token(),
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
        emit(method, calendar)
      })
      .catch((error) => {
        console.warn(error)
      })
    }
  function notExistsGoogleId(google_calendar_id) {
      return !google_calendar_id
    }
  function fetchUser() {
      fetch('api/users', {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': token()
      },
      credentials: 'same-origin'
      })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        authenticatedGoogle.value = json.authenticate
      })
      .catch((error) => {
        console.warn(error)
      })
    }
  function redirectOAuth() {
      window.location.href = '/users/auth/google_oauth2'
    }

onMounted(() => {
  fetchUser()
})
const emit = defineEmits(['close', 'delete', 'create', 'update'])
</script>
