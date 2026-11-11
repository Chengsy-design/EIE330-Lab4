// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VDevelopmentBoard.h for the primary calling header

#include "VDevelopmentBoard__pch.h"
#include "VDevelopmentBoard___024root.h"

VL_ATTR_COLD void VDevelopmentBoard___024root___eval_static(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_static\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void VDevelopmentBoard___024root___eval_initial(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_initial\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__reset__0 = vlSelfRef.reset;
    vlSelfRef.__Vtrigprevexpr___TOP__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__vga_clk__0 
        = vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__vga_clk;
}

VL_ATTR_COLD void VDevelopmentBoard___024root___eval_final(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_final\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VDevelopmentBoard___024root___dump_triggers__stl(VDevelopmentBoard___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool VDevelopmentBoard___024root___eval_phase__stl(VDevelopmentBoard___024root* vlSelf);

VL_ATTR_COLD void VDevelopmentBoard___024root___eval_settle(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_settle\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY((0x64U < __VstlIterCount))) {
#ifdef VL_DEBUG
            VDevelopmentBoard___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("DevelopmentBoard.v", 3, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (VDevelopmentBoard___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelfRef.__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VDevelopmentBoard___024root___dump_triggers__stl(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___dump_triggers__stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VstlTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VDevelopmentBoard___024root___stl_sequent__TOP__0(VDevelopmentBoard___024root* vlSelf);

VL_ATTR_COLD void VDevelopmentBoard___024root___eval_stl(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        VDevelopmentBoard___024root___stl_sequent__TOP__0(vlSelf);
    }
}

extern const VlUnpacked<CData/*2:0*/, 16> VDevelopmentBoard__ConstPool__TABLE_h960ed7eb_0;
extern const VlUnpacked<SData/*15:0*/, 1024> VDevelopmentBoard__ConstPool__TABLE_h046be8a9_0;
extern const VlUnpacked<CData/*7:0*/, 64> VDevelopmentBoard__ConstPool__TABLE_h0e48691a_0;

VL_ATTR_COLD void VDevelopmentBoard___024root___stl_sequent__TOP__0(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___stl_sequent__TOP__0\n"); );
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
    // Body
    vlSelfRef.h_sync = (0x5fU >= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h));
    vlSelfRef.v_sync = (1U >= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v));
    __Vtableidx1 = ((((~ (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state)) 
                      & (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state_prev)) 
                     << 3U) | (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_cur));
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_next 
        = VDevelopmentBoard__ConstPool__TABLE_h960ed7eb_0
        [__Vtableidx1];
    vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__screen_sel 
        = ((2U == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_cur))
            ? 1U : ((4U == (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_cur))
                     ? 2U : 0U));
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT____VdfgRegularize_h61e79979_0_0 
        = ((0x23U <= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v)) 
           & (0x203U > (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v)));
    vlSelfRef.rgb = (((0x90U <= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h)) 
                      & ((0x310U > (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h)) 
                         & (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT____VdfgRegularize_h61e79979_0_0)))
                      ? (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_data)
                      : 0U);
    DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__pix_data_req 
        = ((0x8fU <= (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h)) 
           & ((0x30fU > (IData)(vlSelfRef.DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h)) 
              & (IData)(DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT____VdfgRegularize_h61e79979_0_0)));
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
}

VL_ATTR_COLD void VDevelopmentBoard___024root___eval_triggers__stl(VDevelopmentBoard___024root* vlSelf);

VL_ATTR_COLD bool VDevelopmentBoard___024root___eval_phase__stl(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___eval_phase__stl\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    VDevelopmentBoard___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelfRef.__VstlTriggered.any();
    if (__VstlExecute) {
        VDevelopmentBoard___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VDevelopmentBoard___024root___dump_triggers__act(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___dump_triggers__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk)\n");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @(negedge reset)\n");
    }
    if ((4ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 2 is active: @(posedge DevelopmentBoard.vga_sm_top_inst.vga_clk)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void VDevelopmentBoard___024root___dump_triggers__nba(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___dump_triggers__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk)\n");
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @(negedge reset)\n");
    }
    if ((4ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 2 is active: @(posedge DevelopmentBoard.vga_sm_top_inst.vga_clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VDevelopmentBoard___024root___ctor_var_reset(VDevelopmentBoard___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    VDevelopmentBoard__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VDevelopmentBoard___024root___ctor_var_reset\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->reset = VL_RAND_RESET_I(1);
    vlSelf->B2 = VL_RAND_RESET_I(1);
    vlSelf->B3 = VL_RAND_RESET_I(1);
    vlSelf->B4 = VL_RAND_RESET_I(1);
    vlSelf->B5 = VL_RAND_RESET_I(1);
    vlSelf->h_sync = VL_RAND_RESET_I(1);
    vlSelf->v_sync = VL_RAND_RESET_I(1);
    vlSelf->rgb = VL_RAND_RESET_I(16);
    vlSelf->led1 = VL_RAND_RESET_I(1);
    vlSelf->led2 = VL_RAND_RESET_I(1);
    vlSelf->led3 = VL_RAND_RESET_I(1);
    vlSelf->led4 = VL_RAND_RESET_I(1);
    vlSelf->led5 = VL_RAND_RESET_I(1);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__vga_clk = VL_RAND_RESET_I(1);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__screen_sel = VL_RAND_RESET_I(2);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__pix_data = VL_RAND_RESET_I(16);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_meta = VL_RAND_RESET_I(1);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_sync = VL_RAND_RESET_I(1);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_press = VL_RAND_RESET_I(19);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__cnt_release = VL_RAND_RESET_I(19);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state = VL_RAND_RESET_I(1);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_key_debounce__DOT__key_state_prev = VL_RAND_RESET_I(1);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_cur = VL_RAND_RESET_I(3);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_screen_fsm__DOT__st_next = VL_RAND_RESET_I(3);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_h = VL_RAND_RESET_I(10);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_ctrl__DOT__cnt_v = VL_RAND_RESET_I(10);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__bar_color = VL_RAND_RESET_I(16);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__in_glyph = VL_RAND_RESET_I(1);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__bmp_col = VL_RAND_RESET_I(3);
    vlSelf->DevelopmentBoard__DOT__vga_sm_top_inst__DOT__u_vga_pic__DOT__row_bits = VL_RAND_RESET_I(8);
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__reset__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__DevelopmentBoard__DOT__vga_sm_top_inst__DOT__vga_clk__0 = VL_RAND_RESET_I(1);
}
