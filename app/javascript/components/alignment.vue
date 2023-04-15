<template>
  <p>連携機能</p>
  <Time v-bind:dayOfSchedule="'morning'">
  </Time>
  <Time v-bind:dayOfSchedule="'afterNoon'">
  </Time>
  <Time v-bind:dayOfSchedule="'fullTime'">
  </Time>
  <button v-on:click="fetchTimes">保存</button>
  <button v-on:click="kakunin">確認</button>
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
import { ref, computed, onMounted, provide } from 'vue'
import Confirm from './confirm.vue'
import Time from './time.vue'
import { useToast } from "vue-toastification"

const toast = useToast()
const props = defineProps({
  calendars: Array
})
const emit = defineEmits(['close', 'delete', 'create', 'update'])
// 時刻設定用
const morningStartHour = ref(8)
const morningStartMinit = ref(0)
const morningEndHour = ref(12)
const morningEndMinit = ref(0)
const afterNoonStartHour = ref(13)
const afterNoonStartMinit = ref(0)
const afterNoonEndHour = ref(17)
const afterNoonEndMinit = ref(0)
const fullTimeStartHour = ref(8)
const fullTimeStartMinit = ref(0)
const fullTimeEndHour = ref(17)
const fullTimeEndMinit = ref(0)
const workingTimes = ref({
  morningStartHour: morningStartHour.value,
  morningStartMinit: morningStartMinit.value,
  morningEndHour: morningEndHour.value,
  morningEndMinit: morningEndMinit.value,
  afterNoonStartHour: afterNoonStartHour.value,
  afterNoonStartMinit: afterNoonStartMinit.value,
  afterNoonEndHour: afterNoonEndHour.value,
  afterNoonEndMinit: afterNoonEndMinit.value,
  fullTimeStartHour: fullTimeStartHour.value,
  fullTimeStartMinit: fullTimeStartMinit.value,
  fullTimeEndHour: fullTimeEndHour.value,
  fullTimeEndMinit: fullTimeEndMinit.value,
})
provide('workingTimes', workingTimes)
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
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(workingTimes),
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
    /*
    workingTimes.value['morningStartHour'] = json.morningStartHour
    workingTimes.value['morningStartMinit'] = json.morningStartMinit
    workingTimes.value['morningEndHour'] = json.morningEndHour
    workingTimes.value['morningEndMinit'] = json.morningEndMinit
    workingTimes.value['afterNoonStartHour'] = json.afterNoonStartHour
    workingTimes.value['afterNoonStartMinit'] = json.afterNoonStartMinit
    workingTimes.value['afterNoonEndHour'] = json.afterNoonEndHour
    workingTimes.value['afterNoonEndMinit'] = json.afterNoonEndMinit
    workingTimes.value['fullTimeStartHour'] = json.fullTimeStartHour
    workingTimes.value['fullTimeStartMinit'] = json.fullTimeStartMinit
    workingTimes.value['fullTimeEndHour'] = json.fullTimeEndHour
    workingTimes.value['fullTimeEndMinit'] = json.fullTimeEndMinit
    */
  })
  .catch((error) => {
    console.warn(error)
  })
}
onMounted(() => {
  fetchUser()
})
function fetchTimes() {
  fetch('api/times', {
  method: 'PUT',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-Token': token(),
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(workingTimes.value),
  credentials: 'same-origin'
  })
  .then((response) => {
    return response.json()
  })
  .then((json) => {
   
  })
  .catch((error) => {
    console.warn(error)
  })
}
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
