export type AvailabilityDay =
  | 'Monday'
  | 'Tuesday'
  | 'Wednesday'
  | 'Thursday'
  | 'Friday'
  | 'Saturday'
  | 'Sunday'

export type BarberAvailability = {
  id: string
  barberId: string
  dayOfWeek: AvailabilityDay
  startTime: string
  endTime: string
  isActive: boolean
}

export type BarberAvailabilityInput = {
  dayOfWeek: AvailabilityDay
  startTime?: string
  endTime?: string
  isActive: boolean
}

export type UpsertBarberAvailabilityRequest = {
  availability: BarberAvailabilityInput[]
}

export type BarberDayOff = {
  id: string
  barberId: string
  date: string
  reason?: string
}

export type CreateBarberDayOffRequest = {
  date: string
  reason?: string
}

export type BarberSlot = {
  startTime: string
  endTime: string
  available: boolean
}
