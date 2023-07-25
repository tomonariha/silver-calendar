<template>
  <div
    class="overlay"
    v-show="showAlignmentForm"
    v-on:click.self="emit('close')">
    <div class="content">
      <section>
        <h3 class="headline-lg">外部カレンダーに反映する</h3>
        <Confirm
          v-bind:showConfirm="Boolean(confirmedCalendar)"
          v-bind:message="'削除します。よろしいですか？'"
          v-on:execution="
            fetchGoogleCalendar(confirmedCalendar, requestMethods['delete'])
          "
          v-on:cancel="cancelConfirm">
        </Confirm>
        <div class="overlay" v-show="isFetching">
          <p class="fetching">反映しています。しばらくお待ちください</p>
        </div>
        <div class="time-form">
          <section>
            <h4 class="headline-md">時刻の設定</h4>
            <p class="m-2">
              Googleカレンダーに反映する際の時刻を設定します
            </p>
            <Time v-bind:dayOfSchedule="'morning'"> </Time>
            <Time v-bind:dayOfSchedule="'afterNoon'"> </Time>
            <Time v-bind:dayOfSchedule="'fullTime'"> </Time>
            <div class="content-center">
              <button class="btn btn-primary my-2" v-on:click="fetchTimes">
                時刻を保存
              </button>
            </div>
          </section>
        </div>
        <div v-show="errors.length > 0">
          <b>以下のエラーの修正をお願いします:</b>
          <ul>
            <li v-for="error in errors" :key="error.id">{{ error }}</li>
          </ul>
        </div>
        <div class="google-calendar my-2">
          <section>
            <h4 class="headline-md">予定をGoogleカレンダーへ反映する</h4>
            <div class="my-2" v-if="notAuthenticatedGoogle">
              <p class="fs-6 m-2">
                Googleカレンダーに反映するにはGoogle認証が必要です
              </p>
              <div v-on:click="redirectOAuth" class="google-button">
                <img :src="googleButton" alt="google-login" />
              </div>
            </div>
            <div class="my-2 content-center" v-else>
              <span class="auth-completed my-2 fs-6 text-primary rounded">Google認証完了</span>
              <p class="fs-6 m-2" v-show="props.calendars.length > 0">
                「追加」ボタンでGoogleカレンダーへ反映できます
              </p>
            </div>
            <div class="exist-calendars-area my-2 rounded">
              <div class="have-no-calendar content-center p-2 my-2 rounded" v-if="!(props.calendars.length > 0)">
                <p class="fs-5 my-2">反映できるカレンダーがまだありません。</p>
                <p class="fs-5 my-2">カレンダーに勤務予定を入れてください。</p>
              </div>
              <div v-else>
                <div
                  class="my-2 alignment-button-area p-2 rounded"
                  v-for="(calendar, index) in slicedCalendars"
                  :key="index">
                  <span class="calendar_year__body m-2"
                    >{{ calendar.year }}年</span
                  >
                  <button
                    class="btn btn-primary ms-1"
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
                    class="btn btn-primary ms-1"
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
                    class="btn btn-sm ms-1 inconspicuous-button"
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
          </section>
        </div>
        <button
          class="btn btn-sm inconspicuous-button my-2"
          v-on:click="emit('close')">
          キャンセル
        </button>
      </section>
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
  showAlignmentForm: Boolean,
  calendars: Array
})
const emit = defineEmits(['close', 'reflect'])
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
  const request = new FetchRequest('put', 'api/v1/times', {
    body: JSON.stringify(workingTimes.value)
  })
  const response = await request.perform()
  if (response.ok) {
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
  const request = new FetchRequest(
    `${method}`,
    `api/v1/calendars/${calendar.year}/alignment`,
    { body: JSON.stringify(workingTimes.value) }
  )
  const response = await request.perform()
  if (response.ok) {
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
  if (response.ok) {
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
  currentPage.value += displayRange + 1
}
function decreasePage() {
  currentPage.value -= displayRange + 1
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

<style scoped>
.content {
  z-index: 2;
  max-width: 500px;
  padding: 1em;
  background: #fff;
  overflow-y: auto;
  max-height: 94%;
}
.fetching {
  z-index: 4;
  max-width: 400px;
  padding: 1em;
  background: #fff;
}
.alignment-button-area {
  display: inline-block;
  text-align: end;
  border: solid 1px lightgray;
}
.have-no-calendar {
  border: solid 1px lightgray;
}
.auth-completed {
  display: inline-block;
  border: solid 2px #0d6efd;
  padding: 4px;
}
</style>
