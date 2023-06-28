<template>
  <div class="rounded my-2 p-2 settings">
    <section>
      <h2 class="fs-5 my-2">条件から勤務予定を設定する</h2>
      <div id="overlay" v-show="confirmedSetting" v-on:click.self="cancelConfirm">
        <div id="confirm">
          <Confirm
            v-bind:message="'削除します。よろしいですか？'"
            v-on:execution="deleteSetting(confirmedSetting.id)"
            v-on:cancel="cancelConfirm">
          </Confirm>
          </div>
        </div>
      <div class="settings-area">
        <span class="have-no-settings" v-show="!(props.settings.length > 0)"
          >まだ条件がありません
        </span>
        <div v-for="setting in slicedSettings" :key="setting.id">
          <span
            class="setting-periods m-2 fs-6 rounded"
            v-bind:class="{ selected: settingId === setting.id }">
            {{ setting.period_start_at }} 〜 {{ setting.period_end_at }}
          </span>
          <div class="schedules-view">
            <span>日:</span>
            <ScheduleIcon
              v-bind:schedule="setting.schedule_of_sunday"
            >
            </ScheduleIcon>
            <span>月:</span>
            <ScheduleIcon
              v-bind:schedule="setting.schedule_of_monday"
            >
            </ScheduleIcon>
            <span>火:</span>
            <ScheduleIcon
              v-bind:schedule="setting.schedule_of_tuesday"
            >
            </ScheduleIcon>
            <span>水:</span>
            <ScheduleIcon
              v-bind:schedule="setting.schedule_of_wednesday"
            >
            </ScheduleIcon>
            <span>木:</span>
            <ScheduleIcon
              v-bind:schedule="setting.schedule_of_thursday"
            >
            </ScheduleIcon>
            <span>金:</span>
            <ScheduleIcon
              v-bind:schedule="setting.schedule_of_friday"
            >
            </ScheduleIcon>
            <span>土:</span>
            <ScheduleIcon
              v-bind:schedule="setting.schedule_of_saturday"
            >
            </ScheduleIcon>
          </div>
          <button
            v-on:click="editSetting(setting)"
            class="btn btn-sm inconspicuous-button ms-1">
            編集
          </button>
          <button
            v-on:click="reflectSetting(setting)"
            class="btn btn-sm btn-primary ms-1">
            適用
          </button>
          <span v-on:click="confirmDialog(setting)" class="delete-button ms-1"
            >削除</span
          >
        </div>
      </div>
      <div class="pagenation my-2">
        <span v-for="(pageNumber, index) in displayPageNumbers" :key="index">
          <span
            class="page-number m-1 fs-5"
            v-bind:class="{ 'current-page': currentPage === pageNumber }"
            v-on:click="updatePageNumber(pageNumber, index)">
            {{ pageNumber }}
          </span>
        </span>
      </div>
      <div class="d-flex justify-content-center">
        <button class="btn btn-primary my-2 new-settings-button" v-on:click="newSetting()">
          新しい条件を作る
        </button>
      </div>
      <div id="overlay" v-show="showSettingModal" v-on:click.self="closeSettingModal">
        <div id="form">
          <div class="form-area">
            <section class="mb-4">
              <h3 class="fs-5 my-2" v-if="settingId">条件の編集</h3>
              <h3 class="fs-5 my-2" v-else>新しい条件の登録</h3>
              <section>
                <h4 class="fs-6 my-2 headline">条件を適用する期間</h4>
                <label for="startAt" class="fs-6 m-2">開始日：</label>
                <select id="start_month_select" name="startAt" v-model="selectedStartMonth">
                  <option v-for="month in 12" :key="month">
                    {{ month }}
                  </option>
                </select>
                <span class="fs-6 m-1">月</span>
                <select id="start_day_select" v-model="selectedStartDay">
                  <option v-for="date in lastDate(selectedStartMonth)" :key="date">
                    {{ date }}
                  </option>
                </select>
                <span class="fs-6 m-1">日</span>
                <br />
                <label for="endAt" class="fs-6 m-2">終了日：</label>
                <select id="end_month_select" name="endAt" v-model="selectedEndMonth">
                  <option v-for="month in 12" :key="month">
                    {{ month }}
                  </option>
                </select>
                <span class="fs-6 m-1">月</span>
                <select id="end_day_select" v-model="selectedEndDay">
                  <option v-for="date in lastDate(selectedEndMonth)" :key="date">
                    {{ date }}
                  </option>
                </select>
                <span class="fs-6 m-1">日</span>
              </section>
              <section class="my-4">
                <h4 class="fs-6 my-2 headline">この期間の勤務日数</h4>
                <p class="m-2 text-info" v-show="notSpecifiedTotalDays">指定する場合はチェックを外してください</p>
                <label for="check_specified_total_days" class="m-2">指定しない</label>
                <input
                  type="checkbox"
                  class="m-2"
                  id="check_specified_total_days"
                  v-model="notSpecifiedTotalDays" />
                <br />
                <input
                  id="specified_total_days"
                  class="m-2"
                  type="number"
                  v-show="specifiedTotalDays"
                  v-model="totalWorkingDays" />
                <span class="m-2" v-show="specifiedTotalDays">日</span>
              </section>
              <section class="weekday-nav my-4">
                <h4 class="fs-6 my-2 headline">曜日毎の勤務予定</h4>
                <span class="m-2"
                  >{{ weekdayJp[weekdayNumber] }}曜日の予定</span
                >
                <button class="me-1" v-on:click="decreaseWeekday">＜ {{ previousWeekday }}曜日</button>
                <button class="me-1" v-on:click="increaseWeekday">＞ {{ nextWeekday }}曜日</button>
                <div class="m-2 weekday-nav__body">
                  <p class="my-2 text-info">期間内のこの曜日全てに下の予定が入ります</p>
                  <input
                    type="radio"
                    id="none"
                    value="None"
                    v-model="schedules[weekdayNumber]" />
                  <label for="none" class="schedule-label">予定なし</label>
                  <img :src="none" alt="none" class="schedule-icon-small" />
                  <br />
                  <input
                    type="radio"
                    id="full-time"
                    value="full-time"
                    v-model="schedules[weekdayNumber]" />
                  <label for="full-time" class="schedule-label">全日出勤</label>
                  <img :src="fullTime" alt="fullTime" class="schedule-icon-small" />
                  <br />
                  <input
                    type="radio"
                    id="morning"
                    value="morning"
                    v-model="schedules[weekdayNumber]" />
                  <label for="morning" class="schedule-label">午前出勤</label>
                  <img :src="morning" alt="morning" class="schedule-icon-small" />
                  <br />
                  <input
                    type="radio"
                    id="afternoon"
                    value="afternoon"
                    v-model="schedules[weekdayNumber]" />
                  <label for="afternoon" class="schedule-label">午後出勤</label>
                  <img :src="afterNoon" alt="afterNoon" class="schedule-icon-small" />
                  <br />
                  <input
                    type="radio"
                    id="off"
                    value="off"
                    v-model="schedules[weekdayNumber]" />
                  <label for="off" class="schedule-label">休み</label>
                  <img :src="off" alt="off" class="schedule-icon-small" />
                  <br />
                </div>
                <button
                  class="btn btn-primary my-2"
                  v-if="settingId"
                  v-on:click="updateSetting(settingId)">
                  変更
                </button>
                <button
                  class="btn btn-primary mt-4"
                  v-else
                  v-on:click="createSetting()">
                  登録
                </button>
              </section>
            </section>
          </div>
          <div class="error-area rounded" v-if="errors.length > 0">
            <b>以下のエラーの修正をお願いします:</b>
            <ul>
              <li v-for="error in errors" :key="error.id">{{ error }}</li>
            </ul>
          </div>
          <button class="btn btn-sm inconspicuous-button my-2" v-on:click="closeSettingModal">
            キャンセル
          </button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import Confirm from './confirm.vue'
import ScheduleIcon from './scheduleIcon.vue'
import { useToast } from 'vue-toastification'
import fullTime from '../../assets/images/fulltime.svg?url'
import morning from '../../assets/images/morning.svg?url'
import afterNoon from '../../assets/images/afternoon.svg?url'
import off from '../../assets/images/off.svg?url'
import none from '../../assets/images/none.svg?url'

const toast = useToast()
const props = defineProps({
  year: Number,
  settings: Array
})
const emit = defineEmits(['update', 'create', 'delete', 'reflect'])
const settingId = ref('')
const showSettingModal = ref(false)
function closeSettingModal() {
  showSettingModal.value = false
}
// CRUD
function token() {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta ? meta.getAttribute('content') : ''
}
function createSetting() {
  const startDay = new Date(
    props.year,
    selectedStartMonth.value - 1,
    selectedStartDay.value
  )
  const endDay = new Date(
    props.year,
    selectedEndMonth.value - 1,
    selectedEndDay.value
  )
  if (totalDaysValidation(startDay, endDay)) {
    return
  }
  if (periodValidation(startDay, endDay)) {
    return
  }
  const setting = {
    period_start_at: startDay.toDateString(),
    period_end_at: endDay.toDateString(),
    total_working_days: setTotalWorkingDays(),
    schedule_of_sunday: schedules.value[0],
    schedule_of_monday: schedules.value[1],
    schedule_of_tuesday: schedules.value[2],
    schedule_of_wednesday: schedules.value[3],
    schedule_of_thursday: schedules.value[4],
    schedule_of_friday: schedules.value[5],
    schedule_of_saturday: schedules.value[6]
  }
  fetch(`api/calendars/${props.year}/settings`, {
    method: 'POST',
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token(),
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(setting),
    credentials: 'same-origin'
  })
    .then((response) => {
      return response.json()
    })
    .then((json) => {
      toast('作成しました')
      setting['id'] = json.id
      emit('create', setting)
    })
    .catch((error) => {
      console.warn(error)
    })
  closeSettingModal()
}
function updateSetting(settingId) {
  const startDay = new Date(
    props.year,
    selectedStartMonth.value - 1,
    selectedStartDay.value
  )
  const endDay = new Date(
    props.year,
    selectedEndMonth.value - 1,
    selectedEndDay.value
  )
  if (totalDaysValidation(startDay, endDay)) {
    return
  }
  if (periodValidation(startDay, endDay)) {
    return
  }
  const setting = {
    period_start_at: startDay.toDateString(),
    period_end_at: endDay.toDateString(),
    total_working_days: setTotalWorkingDays(),
    schedule_of_sunday: schedules.value[0],
    schedule_of_monday: schedules.value[1],
    schedule_of_tuesday: schedules.value[2],
    schedule_of_wednesday: schedules.value[3],
    schedule_of_thursday: schedules.value[4],
    schedule_of_friday: schedules.value[5],
    schedule_of_saturday: schedules.value[6]
  }
  fetch(`api/calendars/${props.year}/settings/${settingId}`, {
    method: 'PUT',
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token(),
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(setting),
    credentials: 'same-origin'
  })
    .then(() => {
      toast('更新しました')
      setting['id'] = settingId
      emit('update', setting)
    })
    .catch((error) => {
      console.warn(error)
    })
  closeSettingModal()
}
function editSetting(setting) {
  const startDay = new Date(setting.period_start_at)
  const endDay = new Date(setting.period_end_at)
  totalWorkingDays.value = setting.total_working_days
  schedules.value[0] = setting.schedule_of_sunday
  schedules.value[1] = setting.schedule_of_monday
  schedules.value[2] = setting.schedule_of_tuesday
  schedules.value[3] = setting.schedule_of_wednesday
  schedules.value[4] = setting.schedule_of_thursday
  schedules.value[5] = setting.schedule_of_friday
  schedules.value[6] = setting.schedule_of_saturday
  selectedStartMonth.value = startDay.getMonth() + 1
  selectedStartDay.value = startDay.getDate()
  selectedEndMonth.value = endDay.getMonth() + 1
  selectedEndDay.value = endDay.getDate()
  settingId.value = setting.id
  weekdayNumber.value = 0
  if (setting.total_working_days) {
    notSpecifiedTotalDays.value = false
  } else {
    notSpecifiedTotalDays.value = true
  }
  showSettingModal.value = true
}
function deleteSetting(id) {
  cancelConfirm()
  fetch(`api/calendars/${props.year}/settings/${id}`, {
    method: 'DELETE',
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': token()
    },
    credentials: 'same-origin'
  })
    .then(() => {
      toast('削除しました')
      resetSettingParams()
      emit('delete', id)
    })
    .catch((error) => {
      console.warn(error)
    })
}
function resetSettingParams() {
  schedules.value[0] = 'off'
  schedules.value[1] = 'None'
  schedules.value[2] = 'None'
  schedules.value[3] = 'None'
  schedules.value[4] = 'None'
  schedules.value[5] = 'None'
  schedules.value[6] = 'off'
  selectedStartMonth.value = 1
  selectedStartDay.value = 1
  selectedEndMonth.value = 1
  selectedEndDay.value = 1
  settingId.value = ''
  totalWorkingDays.value = 0
  weekdayNumber.value = 0
  notSpecifiedTotalDays.value = true
}
function newSetting() {
  resetSettingParams()
  showSettingModal.value = true
}
function reflectSetting(setting) {
  emit('reflect', setting)
}
// フォーム：期間設定
const selectedStartMonth = ref(1)
const selectedStartDay = ref(1)
const selectedEndMonth = ref(1)
const selectedEndDay = ref(1)
function lastDate(selectedMonth) {
  const lastDay = new Date(props.year, selectedMonth, 0)
  return lastDay.getDate()
}
// フォーム：勤務日数指定
const totalWorkingDays = ref(0)
const notSpecifiedTotalDays = ref(true)
const specifiedTotalDays = computed(() => {
  return !notSpecifiedTotalDays.value
})
function setTotalWorkingDays() {
  if (notSpecifiedTotalDays.value) {
    return null
  }
  return totalWorkingDays.value
}
// フォーム：曜日毎の予定入力
const scheduleOfSunday = 'off'
const scheduleOfMonday = 'None'
const scheduleOfTuesday = 'None'
const scheduleOfWednesday = 'None'
const scheduleOfThursday = 'None'
const scheduleOfFriday = 'None'
const scheduleOfSaturday = 'off'
const schedules = ref([
  scheduleOfSunday,
  scheduleOfMonday,
  scheduleOfTuesday,
  scheduleOfWednesday,
  scheduleOfThursday,
  scheduleOfFriday,
  scheduleOfSaturday
])
const weekdayNumber = ref(0)
const weekdayJp = {
  0: '日',
  1: '月',
  2: '火',
  3: '水',
  4: '木',
  5: '金',
  6: '土'
}
const previousWeekday = computed(() => {
  if (weekdayNumber.value === 0) {
    return weekdayJp[6]
  } else {
    return weekdayJp[weekdayNumber.value - 1]
  }
})
const nextWeekday = computed(() => {
  if (weekdayNumber.value === 6) {
    return weekdayJp[0]
  } else {
    return weekdayJp[weekdayNumber.value + 1]
  }
})
function decreaseWeekday() {
  if (weekdayNumber.value === 0) {
    weekdayNumber.value = 6
  } else {
    weekdayNumber.value--
  }
}
function increaseWeekday() {
  if (weekdayNumber.value === 6) {
    weekdayNumber.value = 0
  } else {
    weekdayNumber.value++
  }
}
// ページング
const currentPage = ref(1)
const pageLimit = 5
const displayRange = 1
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
const slicedSettings = computed(() => {
  let start = (currentPage.value - 1) * pageLimit
  let end = start + pageLimit
  return props.settings.slice(start, end)
})
const displayPageNumbers = computed(() => {
  let pages = []
  const totalPages = Math.ceil(props.settings.length / pageLimit)
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
const confirmedSetting = ref(null)
function confirmDialog(setting) {
  confirmedSetting.value = setting
}
function cancelConfirm() {
  confirmedSetting.value = null
}
// バリデーション
const errors = ref([])
function formatMonth(month) {
  return month.toString().padStart(2, '0')
}
function formatDay(day) {
  return day.toString().padStart(2, '0')
}
function formatDate(date) {
  return (
    date.getFullYear() +
    '-' +
    formatMonth(date.getMonth() + 1) +
    '-' +
    formatDay(date.getDate())
  )
}
function periodValidation(startDay, endDay) {
  errors.value = []
  let invalid = false
  if (
    !selectedStartMonth.value ||
    !selectedStartDay.value ||
    !selectedEndMonth.value ||
    !selectedEndDay.value
  ) {
    errors.value.spush('開始日と終了日を入力してください。')
    return true
  }
  if (startDay > endDay) {
    errors.value.push('開始日が終了日以前になるようにしてください。')
    return true
  }
  for (let setting of props.settings) {
    if (setting.id === settingId.value) {
      continue
    }
    const settingStartAt = setting.period_start_at
    const settingEndAt = setting.period_end_at
    const formatedStartDay = formatDate(startDay)
    const formatedEndDay = formatDate(endDay)
    if (
      (formatedStartDay <= settingStartAt &&
        formatedEndDay >= settingStartAt) ||
      (formatedStartDay <= settingEndAt && formatedEndDay >= settingEndAt) ||
      (formatedStartDay > settingStartAt && formatedEndDay < settingEndAt)
    ) {
      errors.value.push('他の条件の期間と重ならないようにしてください。')
      invalid = true
      break
    }
  }
  if (invalid) {
    return true
  }
}
function totalDaysValidation(startDay, endDay) {
  errors.value = []
  let calendar = []
  for (
    let day = new Date(startDay.getTime());
    day <= endDay;
    day.setDate(day.getDate() + 1)
  ) {
    calendar.push(day)
  }
  if (totalWorkingDays.value < 0 || totalWorkingDays.value > calendar.length) {
    errors.value.push(
      `勤務日数は０以上期間内の日数(${calendar.length})以下にしてください。`
    )
    return true
  }
}
watch(
  () => props.year,
  () => {
    errors.value = []
  }
)
</script>

<style>
.settings {
  border: 1px solid black;
  width: 100%;
  min-width: 400px;
}
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
#form {
  z-index: 2;
  max-width: 400px;
  padding: 1em;
  background: #fff;
}
#confirm {
  z-index: 3;
  max-width: 400px;
  padding: 2em;
  background: #fff;
}
.btn.btn-sm.inconspicuous-button {
  --bs-btn-color: gray;
  --bs-btn-bg: #fff;
  --bs-btn-border-color: gray;
  --bs-btn-hover-color: #fff;
  --bs-btn-hover-bg: gray;
  --bs-btn-hover-border-color: #101112;
  --bs-btn-focus-shadow-rgb: 49, 132, 253;
  --bs-btn-active-color: #fff;
  --bs-btn-active-bg: rgb(107, 107, 107);
  --bs-btn-active-border-color: rgb(50, 50, 50);
  --bs-btn-active-shadow: inset 0 3px 5px rgba(0, 0, 0, .125);
  --bs-btn-disabled-color: #fff;
  --bs-btn-disabled-bg: rgb(188, 188, 188);
  --bs-btn-disabled-border-color: #b0b2b5;
}
.delete-button {
  text-decoration: underline;
  cursor: pointer;
}
.setting-periods {
  display: inline-block;
  width: 220px;
}
.settings-area {
  height: 220px;
  background-color: gainsboro;
}
.new-settings-button {
  width: 250px;
}
.page-number {
  text-decoration: underline;
  cursor: pointer;
}
.have-no-settings {
  display: inline-block;
  vertical-align: middle;
}
.current-page {
  font-weight: bold;
}
#specified_total_days {
  width: 60px;
}
.schedule-label {
  width: 68px;
}
.error-area {
  background: #ffbeda;
  border: 1px solid #ff5192;
}
.schedules-view {
  display: inline-block;
}
</style>
