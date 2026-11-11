// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VDevelopmentBoard.h for the primary calling header

#include "VDevelopmentBoard__pch.h"
#include "VDevelopmentBoard___024root.h"

void VDevelopmentBoard___024root___eval_act(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void VDevelopmentBoard___024root___nba_sequent__TOP__0(VDevelopmentBoard___024root* vlSelf);
void VDevelopmentBoard___024root___nba_sequent__TOP__1(VDevelopmentBoard___024root* vlSelf);

void VDevelopmentBoard___024root___eval_nba(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VDevelopmentBoard___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((6ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VDevelopmentBoard___024root___nba_sequent__TOP__1(vlSelf);
    }
}

VL_INLINE_OPT void VDevelopmentBoard___024root___nba_sequent__TOP__0(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___nba_sequent__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__vga_clk 
        = ((IData)(vlSelfRef.reset) & (~ (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__vga_clk)));
}

extern const VlUnpacked<CData/*2:0*/, 16> VDevelopmentBoard__ConstPool__TABLE_h960ed7eb_0;
extern const VlUnpacked<SData/*15:0*/, 1024> VDevelopmentBoard__ConstPool__TABLE_h046be8a9_0;
extern const VlUnpacked<CData/*7:0*/, 64> VDevelopmentBoard__ConstPool__TABLE_h0e48691a_0;

VL_INLINE_OPT void VDevelopmentBoard___024root___nba_sequent__TOP__1(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___nba_sequent__TOP__1\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    SData/*9:0*/ DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x;
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x = 0;
    SData/*9:0*/ DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_y;
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_y = 0;
    CData/*0:0*/ DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__pix_data_req;
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__pix_data_req = 0;
    CData/*0:0*/ DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT____VdfgRegularize_h61e79979_0_0;
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT____VdfgRegularize_h61e79979_0_0 = 0;
    CData/*2:0*/ DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph;
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph = 0;
    CData/*2:0*/ DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col;
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col = 0;
    CData/*3:0*/ __Vtableidx1;
    __Vtableidx1 = 0;
    SData/*9:0*/ __Vtableidx2;
    __Vtableidx2 = 0;
    CData/*5:0*/ __Vtableidx3;
    __Vtableidx3 = 0;
    IData/*18:0*/ __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press;
    __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press = 0;
    IData/*18:0*/ __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release;
    __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release = 0;
    SData/*9:0*/ __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h;
    __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h = 0;
    // Body
    __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press 
        = vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press;
    __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release 
        = vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release;
    __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h 
        = vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h;
    if (vlSelfRef.reset) {
        vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state_prev 
            = vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state;
        if (vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_sync) {
            __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press = 0U;
            if ((0x7a11fU != vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release)) {
                __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release 
                    = (0x7ffffU & ((IData)(1U) + vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release));
            }
        } else {
            if ((0x7a11fU != vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press)) {
                __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press 
                    = (0x7ffffU & ((IData)(1U) + vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press));
            }
            __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release = 0U;
        }
        __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h 
            = ((0x31fU == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h))
                ? 0U : (0x3ffU & ((IData)(1U) + (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h))));
        vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v 
            = (((0x20cU == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v)) 
                & (0x31fU == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h)))
                ? 0U : (0x3ffU & ((0x31fU == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h))
                                   ? ((IData)(1U) + (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v))
                                   : (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v))));
        vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_data 
            = ((0U == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__screen_sel))
                ? (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__bar_color)
                : ((1U == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__screen_sel))
                    ? (((IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph) 
                        & ((IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__row_bits) 
                           >> (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__bmp_col)))
                        ? 0xffffU : 0U) : ((2U == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__screen_sel))
                                            ? (((IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph) 
                                                & ((IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__row_bits) 
                                                   >> (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__bmp_col)))
                                                ? 0xffffU
                                                : 0U)
                                            : (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__bar_color))));
        vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_cur 
            = vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_next;
        if (((~ (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_sync)) 
             & (0x7a11fU == vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press))) {
            vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state = 0U;
        } else if (((IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_sync) 
                    & (0x7a11fU == vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release))) {
            vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state = 1U;
        }
    } else {
        vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state_prev = 0U;
        __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press = 0U;
        __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release = 0U;
        __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h = 0U;
        vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v = 0U;
        vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_data = 0U;
        vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_cur = 1U;
        vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state = 0U;
    }
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h 
        = __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h;
    vlSelfRef.h_sync = (0x5fU >= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h));
    vlSelfRef.v_sync = (1U >= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v));
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT____VdfgRegularize_h61e79979_0_0 
        = ((0x23U <= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v)) 
           & (0x203U > (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v)));
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__screen_sel 
        = ((2U == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_cur))
            ? 1U : ((4U == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_cur))
                     ? 2U : 0U));
    vlSelfRef.rgb = (((0x90U <= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h)) 
                      & ((0x310U > (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h)) 
                         & (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT____VdfgRegularize_h61e79979_0_0)))
                      ? (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_data)
                      : 0U);
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__pix_data_req 
        = ((0x8fU <= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h)) 
           & ((0x30fU > (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h)) 
              & (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT____VdfgRegularize_h61e79979_0_0)));
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press 
        = __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press;
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release 
        = __Vdly__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release;
    if (DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__pix_data_req) {
        DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_y 
            = (0x3ffU & ((IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v) 
                         - (IData)(0x23U)));
        DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x 
            = (0x3ffU & ((IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h) 
                         - (IData)(0x8fU)));
    } else {
        DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_y = 0x3ffU;
        DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x = 0x3ffU;
    }
    __Vtableidx1 = ((((~ (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state)) 
                      & (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state_prev)) 
                     << 3U) | (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_cur));
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_next 
        = VDevelopmentBoard__ConstPool__TABLE_h960ed7eb_0
        [__Vtableidx1];
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_sync 
        = ((1U & (~ (IData)(vlSelfRef.reset))) || (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_meta));
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph = 0U;
    __Vtableidx2 = DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x;
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__bar_color 
        = VDevelopmentBoard__ConstPool__TABLE_h046be8a9_0
        [__Vtableidx2];
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col = 0U;
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph = 0U;
    if ((((0U != (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__screen_sel)) 
          & (0xd0U <= (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_y))) 
         & (0x110U > (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_y)))) {
        if ((1U == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__screen_sel))) {
            if (((0x90U <= (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)) 
                 & (0xd0U > (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)))) {
                vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph = 1U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col = 2U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph = 0U;
            } else if (((0xf0U <= (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)) 
                        & (0x130U > (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)))) {
                vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph = 1U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col = 6U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph = 1U;
            } else if (((0x150U <= (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)) 
                        & (0x190U > (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)))) {
                vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph = 1U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col = 2U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph = 2U;
            } else if (((0x1b0U <= (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)) 
                        & (0x1f0U > (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)))) {
                vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph = 1U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col = 6U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph = 3U;
            }
        } else if ((2U == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__screen_sel))) {
            if (((0xc0U <= (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)) 
                 & (0x100U > (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)))) {
                vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph = 1U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col = 0U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph = 4U;
            } else if (((0x120U <= (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)) 
                        & (0x160U > (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)))) {
                vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph = 1U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col = 4U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph = 5U;
            } else if (((0x180U <= (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)) 
                        & (0x1c0U > (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_x)))) {
                vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph = 1U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col = 0U;
                DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph = 6U;
            }
        }
    }
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__bmp_col 
        = (7U & ((IData)(7U) - (((IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__pix_data_req)
                                  ? (0x7fU & (((IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h) 
                                               - (IData)(0x8fU)) 
                                              >> 3U))
                                  : 7U) - (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph_col))));
    __Vtableidx3 = ((0x38U & ((((IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__pix_data_req)
                                 ? (0x7fU & (((IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v) 
                                              - (IData)(0x23U)) 
                                             >> 3U))
                                 : 7U) - (IData)(2U)) 
                              << 3U)) | (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__glyph));
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__row_bits 
        = VDevelopmentBoard__ConstPool__TABLE_h0e48691a_0
        [__Vtableidx3];
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_meta 
        = ((1U & (~ (IData)(vlSelfRef.reset))) || (IData)(vlSelfRef.B2));
}

void VDevelopmentBoard___024root___eval_triggers__act(VDevelopmentBoard___024root* vlSelf);

bool VDevelopmentBoard___024root___eval_phase__act(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_phase__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<3> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    VDevelopmentBoard___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        VDevelopmentBoard___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool VDevelopmentBoard___024root___eval_phase__nba(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_phase__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        VDevelopmentBoard___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VDevelopmentBoard___024root___dump_triggers__nba(VDevelopmentBoard___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void VDevelopmentBoard___024root___dump_triggers__act(VDevelopmentBoard___024root* vlSelf);
#endif  // VL_DEBUG

void VDevelopmentBoard___024root___eval(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            VDevelopmentBoard___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("DevelopmentBoard.v", 3, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelfRef.__VactIterCount))) {
#ifdef VL_DEBUG
                VDevelopmentBoard___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("DevelopmentBoard.v", 3, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (VDevelopmentBoard___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (VDevelopmentBoard___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void VDevelopmentBoard___024root___eval_debug_assertions(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_debug_assertions\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY((vlSelfRef.clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelfRef.reset & 0xfeU))) {
        Verilated::overWidthError("reset");}
    if (VL_UNLIKELY((vlSelfRef.B2 & 0xfeU))) {
        Verilated::overWidthError("B2");}
    if (VL_UNLIKELY((vlSelfRef.B3 & 0xfeU))) {
        Verilated::overWidthError("B3");}
    if (VL_UNLIKELY((vlSelfRef.B4 & 0xfeU))) {
        Verilated::overWidthError("B4");}
    if (VL_UNLIKELY((vlSelfRef.B5 & 0xfeU))) {
        Verilated::overWidthError("B5");}
}
#endif  // VL_DEBUG
