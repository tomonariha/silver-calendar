<template>
<div class="overlay"
     v-show="showSettingForm"
     v-on:click.self="closeForm">
  <div class="form">
    <div class="form-area">
      <section class="mb-4">
        <h3 class="fs-5 my-2" v-if="settingId">条件の編集</h3>
        <h3 class="fs-5 my-2" v-else>新しい条件の登録</h3>
        <section>
          <h4 class="fs-6 my-1 headline">条件を適用する期間</h4>
          <label for="startAt" class="fs-6 mx-2 my-1">開始日：</label>
          <select
            id="start_month_select"
            name="startAt"
            v-model="selectedStartMonth">
            <option v-for="month in 12" :key="month">
              {{ month }}
            </option>
          </select>
          <span class="fs-6 m-1">月</span>
          <select id="start_day_select" v-model="selectedStartDay">
            <option
              v-for="date in lastDate(selectedStartMonth)"
              :key="date">
              {{ date }}
            </option>
          </select>
          <span class="fs-6 m-1">日</span>
          <br />
          <label for="endAt" class="fs-6 mx-2 my-1">終了日：</label>
          <select
            id="end_month_select"
            name="endAt"
            v-model="selectedEndMonth">
            <option v-for="month in 12" :key="month">
              {{ month }}
            </option>
          </select>
          <span class="fs-6 m-1">月</span>
          <select id="end_day_select" v-model="selectedEndDay">
            <option
              v-for="date in lastDate(selectedEndMonth)"
              :key="date">
              {{ date }}
            </option>
          </select>
          <span class="fs-6 m-1">日</span>
        </section>
        <section class="my-2">
          <h4 class="fs-6 my-1 headline">この期間の勤務日数</h4>
          <p
            class="mx-2 my-1 text-primary"
            v-show="notSpecifiedTotalDays">
            指定する場合はチェックを外してください
          </p>
          <label for="check_specified_total_days" class="mx-2 my-1"
            >指定しない</label
          >
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
        <section class="weekday-nav my-2">
          <h4 class="fs-6 my-1 headline">曜日毎の勤務予定</h4>
          <button class="mx-2 my-1" v-on:click="decreaseWeekday">
            ＜ {{ previousWeekday }}曜日
          </button>
          <span class="mx-2 my-1"
            >{{ weekdayJp[weekdayNumber] }}曜日の予定</span
          >
          <button class="mx-2 my-1" v-on:click="increaseWeekday">
            ＞ {{ nextWeekday }}曜日
          </button>
          <div class="mx-2 my-1 weekday-nav__body">
            <p class="mx-2 my-1 text-primary">
              期間内のこの曜日全てに下の予定が入ります
            </p>
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
            <img
              :src="fullTime"
              alt="fullTime"
              class="schedule-icon-small" />
            <br />
            <input
              type="radio"
              id="morning"
              value="morning"
              v-model="schedules[weekdayNumber]" />
            <label for="morning" class="schedule-label">午前出勤</label>
            <img
              :src="morning"
              alt="morning"
              class="schedule-icon-small" />
            <br />
            <input
              type="radio"
              id="afternoon"
              value="afternoon"
              v-model="schedules[weekdayNumber]" />
            <label for="afternoon" class="schedule-label">午後出勤</label>
            <img
              :src="afterNoon"
              alt="afterNoon"
              class="schedule-icon-small" />
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
    <button
      class="btn btn-sm inconspicuous-button my-2"
      v-on:click="closeForm">
      キャンセル
    </button>
  </div>
</div>
</template>
<script setup>
import { ref, computed, watch, toRefs, inject } from 'vue'
import { useToast } from 'vue-toastification'
import { FetchRequest } from '@rails/request.js'
import fullTime from '../../assets/images/fulltime.svg?url'
import morning from '../../assets/images/morning.svg?url'
import afterNoon from '../../assets/images/afternoon.svg?url'
import off from '../../assets/images/off.svg?url'
import none from '../../assets/images/none.svg?url'

const { settings, updateSettings, createToSettings } = inject('settings')
const { setting } = toRefs(props)
watch(setting, () => {
  resetSettingParams()
  if (setting.value) {
    setSetting()
  }
})
const toast = useToast()
const props = defineProps({
  year: Number,
  setting: Object,
  showSettingForm: Boolean
})
const emit = defineEmits(['close'])
const settingId = ref('')
// フォーム：期間設定
const selectedStartMonth = ref(1)
const selectedStartDay = ref(1)
const selectedEndMonth = ref(1)
const selectedEndDay = ref(1)
function lastDate(selectedMonth) {
  const lastDay = new Date(props.year, selectedMonth, 0)
  return lastDay.getDate()
}
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
// CRUD
async function createSetting() {
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
  const request = new FetchRequest('post', `api/v1/calendars/${props.year}/settings.json`,
    {body: JSON.stringify(setting)})
  const response = await request.perform()
  if(response.ok) {
    toast('作成しました')
    const body = await response.json
    setting['id'] = body.id
    createToSettings(setting)
    closeForm()
  } 
}
async function updateSetting(settingId) {
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
  const request = new FetchRequest('put', `api/v1/calendars/${props.year}/settings/${settingId}`,
    {body: JSON.stringify(setting)})
  const response = await request.perform()
  if(response.ok) {
    toast('更新しました')
    setting['id'] = settingId
    updateSettings(setting)
    closeForm()
  }
}
function setSetting() {
  const startDay = new Date(props.setting.period_start_at)
  const endDay = new Date(props.setting.period_end_at)
  totalWorkingDays.value = props.setting.total_working_days
  schedules.value[0] = props.setting.schedule_of_sunday
  schedules.value[1] = props.setting.schedule_of_monday
  schedules.value[2] = props.setting.schedule_of_tuesday
  schedules.value[3] = props.setting.schedule_of_wednesday
  schedules.value[4] = props.setting.schedule_of_thursday
  schedules.value[5] = props.setting.schedule_of_friday
  schedules.value[6] = props.setting.schedule_of_saturday
  selectedStartMonth.value = startDay.getMonth() + 1
  selectedStartDay.value = startDay.getDate()
  selectedEndMonth.value = endDay.getMonth() + 1
  selectedEndDay.value = endDay.getDate()
  settingId.value = props.setting.id
  weekdayNumber.value = 0
  errors.value = []
  if (props.setting.total_working_days) {
    notSpecifiedTotalDays.value = false
  } else {
    notSpecifiedTotalDays.value = true
  }
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
  errors.value = []
  notSpecifiedTotalDays.value = true
}
function closeForm() {
  emit('close')
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
    errors.value.push('開始日と終了日を入力してください。')
    return true
  }
  if (startDay > endDay) {
    errors.value.push('開始日が終了日以前になるようにしてください。')
    return true
  }
  for (let setting of settings.value) {
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
</script>

<style scoped>
.form {
  z-index: 2;
  max-width: 400px;
  padding: 1em;
  background: #fff;
}
</style>
