// this file is based on the redux tutorial
import { createSlice } from '@reduxjs/toolkit'

const initialState = { value: 0 }

const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment(state) {
      state.value++
    },
    decrement(state) {
      state.value--
    },
    incrementByAmount(state, action) {
      state.value += action.payload
    },
  },
})

// counterexample for test, shouldn't capture these reducers
const bla = console.log({
    reducers: {
        dontCaptureThis(state) {
            state.BAD = true;
        }
    }
});

// exported slices should also be captured
export const mySlice = createSlice({
    reducers: {
        captureThisSlice(state) {
            state.yay = true;
        }
    }
});

export const { increment, decrement, incrementByAmount } = counterSlice.actions
export default counterSlice.reducer
