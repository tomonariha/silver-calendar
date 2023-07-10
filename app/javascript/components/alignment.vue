<template>
  <div>
    <h2 class="fs-4 my-2">連携機能</h2>
    <div id="overlay" v-show="confirmedCalendar">
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
        <div v-if="!(props.calendars.length > 0)">カレンダーがまだありません</div>
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
      <Pagenation
        v-bind:array="props.calendars"
        v-bind:pageLimit="pageLimit"
        v-bind:currentPage="currentPage"
        v-bind:displayRange="displayRange"
        v-on:updateCurrentPage="updateCurrentPage"
        v-on:increasePage="increasePage"
        v-on:decreasePage="decreasePage">
      </Pagenation>
      <button class="btn btn-primary my-2" v-on:click="showTimeForm = true">
        時刻の設定
      </button>
    </div>
    <button class="btn btn-dark my-2" v-on:click="emit('close')">閉じる</button>
    <div id="overlay" v-show="showTimeForm">
      <div id="time">
        <div class="time-form">
          <h3 class="fs-5 my-2">時刻の設定</h3>
          <Time v-bind:dayOfSchedule="'morning'"> </Time>
          <Time v-bind:dayOfSchedule="'afterNoon'"> </Time>
          <Time v-bind:dayOfSchedule="'fullTime'"> </Time>
          <button class="btn btn-primary my-2" v-on:click="fetchTimes">
            保存
          </button>
        </div>
        <div v-show="errors.length > 0">
          <b>以下のエラーの修正をお願いします:</b>
          <ul>
            <li v-for="error in errors" :key="error.id">{{ error }}</li>
          </ul>
        </div>
        <button class="btn btn-dark my-2" v-on:click="showTimeForm = false">
          閉じる
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, provide } from 'vue'
import Confirm from './confirm.vue'
import Time from './time.vue'
import Pagenation from './pagenation.vue'
import { useToast } from 'vue-toastification'
import googleButton from '../../assets/images/btn_google_signin_dark_normal_web.png?url'
import { FetchRequest } from '@rails/request.js'

const toast = useToast()
const props = defineProps({
  calendars: Array
})
const emit = defineEmits(['close', 'reflect'])
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
async function fetchTimes() {
  if (timesValidation()) {
    return
  }
  const request = new FetchRequest('put', 'api/v1/times',
    {body: JSON.stringify(workingTimes.value)})
  const response = await request.perform()
  if(response.ok) {
    toast(`保存しました`)
  }
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
const requestMethods = {
  create: 'post',
  delete: 'delete',
  update: 'put'
}
const toActionString = {
  post: '作成',
  delete: '削除',
  put: '更新'
}
const isFetching = ref(false)
async function fetchGoogleCalendar(calendar, method) {
  if (method != 'delete' && timesValidation()) {
    return
  }
  isFetching.value = true
  cancelConfirm()
  const request = new FetchRequest(`${method}`, `api/v1/calendars/${calendar.year}/alignment`,
    {body: JSON.stringify(workingTimes.value)})
  const response = await request.perform()
  if(response.ok) {
    const body = await response.json
    if (method === 'delete') {
      calendar['google_calendar_id'] = null
    } else {
      calendar['google_calendar_id'] = body.google_calendar_id
    }
    toast(`${toActionString[method]}しました`)
    emit('reflect', calendar)
  }
  isFetching.value = false
}
async function fetchUser() {
  const request = new FetchRequest('get', 'api/v1/users')
  const response = await request.perform()
  if(response.ok) {
    const body = await response.json
    authenticatedGoogle.value = body.authenticate
    Object.assign(workingTimes.value, {
      morningStartHour: body.morningStartHour,
      morningStartMinit: body.morningStartMinit,
      morningEndHour: body.morningEndHour,
      morningEndMinit: body.morningEndMinit,
      afterNoonStartHour: body.afterNoonStartHour,
      afterNoonStartMinit: body.afterNoonStartMinit,
      afterNoonEndHour: body.afterNoonEndHour,
      afterNoonEndMinit: body.afterNoonEndMinit,
      fullTimeStartHour: body.fullTimeStartHour,
      fullTimeStartMinit: body.fullTimeStartMinit,
      fullTimeEndHour: body.fullTimeEndHour,
      fullTimeEndMinit: body.fullTimeEndMinit
    })
  }
}
onMounted(() => {
  fetchUser()
})
// 確認ダイアログ
const confirmedCalendar = ref(null)
function confirmDialog(calendar) {
  confirmedCalendar.value = calendar
}
function cancelConfirm() {
  confirmedCalendar.value = null
}
// ページング
const currentPage = ref(1)
const pageLimit = 5
const displayRange = 1
const slicedCalendars = computed(() => {
  let start = (currentPage.value - 1) * pageLimit
  let end = start + pageLimit
  return props.calendars.slice(start, end)
})
function updateCurrentPage(newPage) {
  currentPage.value = newPage
}
function increasePage() {
  currentPage.value += (displayRange + 1)
}
function decreasePage() {
  currentPage.value -= (displayRange + 1)
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
  width: 60%;
  padding: 1em;
  background: #fff;
}
#confirm {
  z-index: 3;
  width: 60%;
  padding: 2em;
  background: #fff;
}
#fetching {
  z-index: 4;
  width: 60%;
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
