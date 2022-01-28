/*
 * This is a part of the TASTE distribution (see https://taste.tools)
 *
 * Copyright (C) 2022 ESA
 * 
 * This is free software; you can redistribute it and/or modify under   
 * terms of the  GNU General Public License as published  by the Free Soft-
 * ware  Foundation;  either version 3,  or (at your option) any later ver-
 * sion. This is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * As a special exception under Section 7 of GPL version 3, you are granted
 * additional permissions described in the GCC Runtime Library Exception,
 * version 3.1, as published by the Free Software Foundation.
 *
 * You should have received a copy of the GNU General Public License and
 * a copy of the GCC Runtime Library Exception along with this program;
 * see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
#pragma once

#include "config.h"

#define PRIME_ADDR (APB_BASE_ADDR + APB_SLV_2_OFF)
#define _start (PRIME_ADDR + 0x0)
#define _input (PRIME_ADDR + 0x4)
#define _output (PRIME_ADDR + 0xC)
#define _done (PRIME_ADDR + 0x14)
#define _hbeat (PRIME_ADDR + 0x18)

void prime_number_init();
uint8_t prime_time(uint32_t num);
