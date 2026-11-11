// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See VDevelopmentBoard.h for the primary calling header

#ifndef VERILATED_VDEVELOPMENTBOARD___024ROOT_H_
#define VERILATED_VDEVELOPMENTBOARD___024ROOT_H_  // guard

#include "verilated.h"


class VDevelopmentBoard__Syms;

class alignas(VL_CACHE_LINE_BYTES) VDevelopmentBoard___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(reset,0,0);
    CData/*0:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__vga_clk;
    VL_IN8(B2,0,0);
    VL_IN8(B3,0,0);
    VL_IN8(B4,0,0);
    VL_IN8(B5,0,0);
    VL_OUT8(h_sync,0,0);
    VL_OUT8(v_sync,0,0);
    VL_OUT8(led1,0,0);
    VL_OUT8(led2,0,0);
    VL_OUT8(led3,0,0);
    VL_OUT8(led4,0,0);
    VL_OUT8(led5,0,0);
    CData/*0:0*/ DevelopmentBoard__DOT__key_auto;
    CData/*1:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__screen_sel;
    CData/*0:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_key_debounce__DOT__key_meta;
    CData/*0:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_key_debounce__DOT__key_sync;
    CData/*0:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_key_debounce__DOT__key_state;
    CData/*0:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_key_debounce__DOT__key_state_prev;
    CData/*2:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_screen_fsm__DOT__st_cur;
    CData/*2:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_screen_fsm__DOT__st_next;
    CData/*0:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_vga_pic__DOT__in_glyph;
    CData/*2:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_vga_pic__DOT__bmp_col;
    CData/*7:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_vga_pic__DOT__row_bits;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__reset__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__DevelopmentBoard__DOT__u_vga_sm_top__DOT__vga_clk__0;
    CData/*0:0*/ __VactContinue;
    VL_OUT16(rgb,15,0);
    SData/*15:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__pix_data;
    SData/*9:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_vga_ctrl__DOT__cnt_h;
    SData/*9:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_vga_ctrl__DOT__cnt_v;
    SData/*15:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_vga_pic__DOT__bar_color;
    IData/*27:0*/ DevelopmentBoard__DOT__div;
    IData/*18:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_key_debounce__DOT__cnt_press;
    IData/*18:0*/ DevelopmentBoard__DOT__u_vga_sm_top__DOT__u_key_debounce__DOT__cnt_release;
    IData/*27:0*/ __Vdly__DevelopmentBoard__DOT__div;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<3> __VactTriggered;
    VlTriggerVec<3> __VnbaTriggered;

    // INTERNAL VARIABLES
    VDevelopmentBoard__Syms* const vlSymsp;

    // CONSTRUCTORS
    VDevelopmentBoard___024root(VDevelopmentBoard__Syms* symsp, const char* v__name);
    ~VDevelopmentBoard___024root();
    VL_UNCOPYABLE(VDevelopmentBoard___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
