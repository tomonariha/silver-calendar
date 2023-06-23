<template>
  <div>
    <section>
      <h2 class="fs-4 my-2">連携機能</h2>
      <div id="overlay" v-show="confirmedCalendar" v-on:click.self="cancelConfirm">
        <div id="confirm">
          <Confirm
            v-bind:message="'削除します。よろしいですか？'"
            v-on:execution="
              fetchGoogleCalendar(confirmedCalendar, requestMethods['delete'])
            "
            v-on:cancel="cancelConfirm">
          </Confirm>
        </div>
      </div>
      <div id="overlay" v-show="isFetching">
        <p id="fetching">反映しています。しばらくお待ちください</p>
      </div>
      <div class="google-calendar my-2">
        <section>
          <h3 class="fs-5 my-2">Googleカレンダー</h3>
          <div class="my-2" v-if="notAuthenticatedGoogle">
            <p class="fs-6 my-2 text-info">
              Googleカレンダーと連携するにはGoogle認証が必要です
            </p>
            <div v-on:click="redirectOAuth" class="google-button">
              <img :src="googleButton" alt="google-login" />
            </div>
          </div>
          <div class="my-2" v-else>
            <p class="fs-6 my-2 text-primary">認証済</p>
          </div>
          <div class="exist-calendars-area my-2">
            <div v-if="haveNoCalendars">カレンダーがまだありません</div>
            <div v-else>
              <div
                class="my-2"
                v-for="(calendar, index) in slicedCalendars"
                :key="index">
                <span class="calendar_year__body me-3">{{ calendar.year }}年</span>
                <button
                  class="btn btn-dark ms-1"
                  v-bind:disabled="
                    calendar.google_calendar_id ||
                    isFetching ||
                    notAuthenticatedGoogle
                  "
                  v-on:click="
                    fetchGoogleCalendar(calendar, requestMethods['create'])
                  ">
                  追加
                </button>
                <button
                  class="btn btn-dark ms-1"
                  v-bind:disabled="
                    notExistsGoogleId(calendar.google_calendar_id) ||
                    isFetching ||
                    notAuthenticatedGoogle
                  "
                  v-on:click="
                    fetchGoogleCalendar(calendar, requestMethods['update'])
                  ">
                  更新
                </button>
                <button
                  class="btn btn-dark ms-1"
                  v-bind:disabled="
                    notExistsGoogleId(calendar.google_calendar_id) ||
                    isFetching ||
                    notAuthenticatedGoogle
                  "
                  v-on:click="confirmDialog(calendar)">
                  削除
                </button>
              </div>
            </div>
          </div>
          <div class="pagenation my-2">
            <span
              class="page-number m-1 fs-5"
              v-for="(pageNumber, index) in displayPageNumbers"
              :key="index">
              <span
                v-bind:class="{ 'current-page': currentPage === pageNumber }"
                v-on:click="updatePageNumber(pageNumber, index)">
                {{ pageNumber }}
              </span>
            </span>
          </div>
          <button class="btn btn-primary my-2" v-on:click="showTimeForm = true">
            時刻の設定
          </button>
          <div id="overlay" v-show="showTimeForm">
            <div id="time">
              <div class="time-form">
                <section>
                  <h3 class="fs-5 my-2">時刻の設定</h3>
                  <Time v-bind:dayOfSchedule="'morning'"> </Time>
                  <Time v-bind:dayOfSchedule="'afterNoon'"> </Time>
                  <Time v-bind:dayOfSchedule="'fullTime'"> </Time>
                  <button class="btn btn-primary my-2" v-on:click="fetchTimes">
                    保存
                  </button>
                </section>
              </div>
              <div v-show="errors.length > 0">
                <b>以下のエラーの修正をお願いします:</b>
                <ul>
                  <li v-for="error in errors" :key="error.id">{{ error }}</li>
                </ul>
              </div>
              <button class="btn btn-sm inconspicuous-button my-2" v-on:click="showTimeForm = false">
                キャンセル
              </button>
            </div>
          </div>
        </section>
      </div>
      <button class="btn btn-sm inconspicuous-button my-2" v-on:click="emit('cancel')">キャンセル</button>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, provide } from 'vue'
import Confirm from './confirm.vue'
import Time from './time.vue'
import { useToast } from 'vue-toastification'
import googleButton from '../../assets/images/btn_google_signin_dark_normal_web.png?url'

const toast = useToast()
const props = defineProps({
  calendars: Array
})
const emit = defineEmits(['cancel', 'delete', 'create', 'update'])
const showTimeForm = ref(false)
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
  morningStartHour,
  morningStartMinit,
  morningEndHour,
  morningEndMinit,
  afterNoonStartHour,
  afterNoonStartMinit,
  afterNoonEndHour,
  afterNoonEndMinit,
  fullTimeStartHour,
  fullTimeStartMinit,
  fullTimeEndHour,
  fullTimeEndMinit
})
function fetchTimes() {
  if (timesValidation()) {
    return
  }
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
    .then(() => {
      toast(`保存しました`)
    })
    .catch((error) => {
      console.warn(error)
    })
}
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
  create: 'POST',
  delete: 'DELETE',
  update: 'PUT'
}
const toActionString = {
  POST: '作成',
  DELETE: '削除',
  PUT: '更新'
}
const isFetching = ref(false)
function fetchGoogleCalendar(calendar, method) {
  if (method != 'DELETE' && timesValidation()) {
    return
  }
  isFetching.value = true
  cancelConfirm()
  fetch(`api/calendars/${calendar.year}/alignment`, {
    method: method,
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
      if (method === 'DELETE') {
        calendar['google_calendar_id'] = null
      } else {
        calendar['google_calendar_id'] = json.google_calendar_id
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
      Object.assign(workingTimes.value, {
        morningStartHour: json.morningStartHour,
        morningStartMinit: json.morningStartMinit,
        morningEndHour: json.morningEndHour,
        morningEndMinit: json.morningEndMinit,
        afterNoonStartHour: json.afterNoonStartHour,
        afterNoonStartMinit: json.afterNoonStartMinit,
        afterNoonEndHour: json.afterNoonEndHour,
        afterNoonEndMinit: json.afterNoonEndMinit,
        fullTimeStartHour: json.fullTimeStartHour,
        fullTimeStartMinit: json.fullTimeStartMinit,
        fullTimeEndHour: json.fullTimeEndHour,
        fullTimeEndMinit: json.fullTimeEndMinit
      })
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
const pageLimit = 5
const displayRange = 1
const haveNoCalendars = computed(() => {
  return !(props.calendars.length > 0)
})
const slicedCalendars = computed(() => {
  let start = (currentPage.value - 1) * pageLimit
  let end = start + pageLimit
  return props.calendars.slice(start, end)
})
function updatePageNumber(pageNumber, index) {
  if (typeof pageNumber === 'number') {
    currentPage.value = pageNumber
    return
  }
  if (index < currentPage.value) {
    currentPage.value -= displayRange + 1
    return
  }
  currentPage.value += displayRange + 1
}
const displayPageNumbers = computed(() => {
  let pages = []
  const totalPages = Math.ceil(props.calendars.length / pageLimit)
  if (totalPages < 2) {
    return
  }
  pages.push(1)
  if (currentPage.value - displayRange > 2) {
    pages.push('...')
  }
  for (let i = -displayRange; i <= displayRange; i++) {
    if (currentPage.value + i > 1 && currentPage.value + i < totalPages) {
      pages.push(currentPage.value + i)
    }
  }
  if (currentPage.value + displayRange < totalPages - 1) {
    pages.push('...')
  }
  pages.push(totalPages)
  return pages
})
// 確認ダイアログ
const confirmedCalendar = ref(null)
function confirmDialog(calendar) {
  confirmedCalendar.value = calendar
}
function cancelConfirm() {
  confirmedCalendar.value = null
}
// バリデーション
const errors = ref([])
const schedules = ['morning', 'afterNoon', 'fullTime']
function timesValidation() {
  errors.value = []
  for (let schedule of schedules) {
    if (
      workingTimes.value[`${schedule}StartHour`] >
        workingTimes.value[`${schedule}EndHour`] ||
      (workingTimes.value[`${schedule}StartHour`] ===
        workingTimes.value[`${schedule}EndHour`] &&
        workingTimes.value[`${schedule}StartMinit`] >
          workingTimes.value[`${schedule}EndMinit`])
    ) {
      errors.value.push(`開始時が終了時以前になるようにしてください。`)
      return true
    }
  }
  return false
}
</script>

<style>
#overlay {
  z-index: 1;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
#time {
  z-index: 2;
  max-width: 500px;
  padding: 1em;
  background: #fff;
}
#confirm {
  z-index: 3;
  max-width: 400px;
  padding: 2em;
  background: #fff;
}
#fetching {
  z-index: 4;
  max-width: 400px;
  padding: 1em;
  background: #fff;
}
.exist-calendars-area {
  width: 600px;
  height: 220px;
}
.page-number {
  text-decoration: underline;
  cursor: pointer;
}
.current-page {
  font-weight: bold;
}
.google-button {
  width: 192px;
  cursor: pointer;
}
</style>
