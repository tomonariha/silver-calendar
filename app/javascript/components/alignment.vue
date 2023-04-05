<template>
  <p>連携機能</p>
  <Time v-bind:dayOfSchedule="'午前：'"
        v-bind:selectedStartHour="selectedMorningStartHour"
        v-bind:selectedStartMinit="selectedMorningStartMinit"
        v-bind:selectedEndHour="selectedMorningEndHour"
        v-bind:selectedEndMinit="selectedMorningEndMinit">
  </Time>
  <Time v-bind:dayOfSchedule="'午後：'"
        v-bind:selectedStartHour="selectedAfterNoonStartHour"
        v-bind:selectedStartMinit="selectedAfterNoonStartMinit"
        v-bind:selectedEndHour="selectedAfterNoonEndHour"
        v-bind:selectedEndMinit="selectedAfterNoonEndMinit">
  </Time>
  <Time v-bind:dayOfSchedule="'全日：'"
        v-bind:selectedStartHour="selectedFullTimeStartHour"
        v-bind:selectedStartMinit="selectedFullTimeStartMinit"
        v-bind:selectedEndHour="selectedFullTimeEndHour"
        v-bind:selectedEndMinit="selectedFullTimeEndMinit">
  </Time>
  <div id=overlay  v-show="confirmedCalendar">
    <div id=content>
      <Confirm v-on:delete="fetchGoogleCalendar(confirmedCalendar, requestMethods['delete'])"
               v-on:cancel="cancelConfirm">
      </Confirm>
    </div>
  </div>
  <div id=overlay v-show="isFetching">
    <p id="content">反映しています。しばらくお待ちください</p>
  </div>
  <p>Googleカレンダー</p>
  <button v-if="notAuthenticatedGoogle" v-on:click="redirectOAuth">Sign in with Google</button>
  <p v-else>認証済</p>
  <div v-if="haveNoCalendars">カレンダーがまだありません</div>
  <div v-else>
    <div v-for="calendar in slicedCalendars" :key="calendar.year">
      <div class="calendar_year__body">{{ calendar.year }}</div>
      <button v-bind:disabled="calendar.google_calendar_id || isFetching" v-on:click="fetchGoogleCalendar(calendar, requestMethods['create'])">追加</button>
      <button v-bind:disabled="notExistsGoogleId(calendar.google_calendar_id) || isFetching" v-on:click="confirmDialog(calendar)">削除</button>
      <button v-bind:disabled="notExistsGoogleId(calendar.google_calendar_id) || isFetching" v-on:click="fetchGoogleCalendar(calendar, requestMethods['update'])">更新</button>
    </div>
  </div>
  <div v-for="pageNumber in totalPages" :key="pageNumber">
    <button v-on:click="updatePageNumber(pageNumber)">{{ pageNumber }}</button>
  </div>
  <br>
  <button v-on:click="emit('close')">閉じる</button>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Confirm from './confirm.vue'
import Time from './time.vue'
import { useToast } from "vue-toastification"

const toast = useToast()
const props = defineProps({
  calendars: Array
})
const emit = defineEmits(['close', 'delete', 'create', 'update'])
// Time
const selectedMorningStartHour = ref(8)
const selectedMorningStartMinit = ref(0)
const selectedMorningEndHour = ref(12)
const selectedMorningEndMinit = ref(0)
const selectedAfterNoonStartHour = ref(13)
const selectedAfterNoonStartMinit = ref(0)
const selectedAfterNoonEndHour = ref(17)
const selectedAfterNoonEndMinit = ref(0)
const selectedFullTimeStartHour = ref(8)
const selectedFullTimeStartMinit = ref(0)
const selectedFullTimeEndHour = ref(17)
const selectedFullTimeEndMinit = ref(0)

// Google
const authenticatedGoogle = ref(false)
const notAuthenticatedGoogle = computed(() => {
  return !authenticatedGoogle.value
})
function redirectOAuth() {
  window.location.href = '/users/auth/google_oauth2'
}
function notExistsGoogleId(google_calendar_id) {
  return !google_calendar_id
}
function token() {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta ? meta.getAttribute('content') : ''
}
const requestMethods = { 
  'create': 'POST',
  'delete': 'DELETE',
  'update': 'PUT'
}
const toActionString = {
  'POST': '作成',
  'DELETE': '削除',
  'PUT': '更新'
}
const isFetching = ref(false)
function fetchGoogleCalendar(calendar, method) {
  isFetching.value = true
  cancelConfirm()
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
    toast(`${toActionString[method]}しました`)
    emit(method, calendar)
  })
  .catch((error) => {
    console.warn(error)
  })
  .finally(() => {
    isFetching.value = false
  })
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
onMounted(() => {
  fetchUser()
})
// ページング
const currentPage = ref(1)
const pageLimit = ref(5)
const haveNoCalendars = computed(() => {
  return !(props.calendars.length > 0)
})
const slicedCalendars = computed(() => {
  let start = (currentPage.value -1) * pageLimit.value
  let end = start + pageLimit.value
  return props.calendars.slice(start, end)
})
const totalPages = computed(() => {
  return Math.ceil(props.calendars.length / pageLimit.value)
})
function updatePageNumber(pageNumber) {
  currentPage.value = pageNumber
}
// 確認ダイアログ
const confirmedCalendar = ref(null)
function confirmDialog(calendar){
  confirmedCalendar.value = calendar
}
function cancelConfirm() {
  confirmedCalendar.value = null
}
</script>
