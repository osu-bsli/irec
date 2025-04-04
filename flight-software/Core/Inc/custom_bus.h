/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : custom_bus.h
  * @brief          : header file for the BSP BUS IO driver
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
*/
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef CUSTOM_BUS_H
#define CUSTOM_BUS_H

#ifdef __cplusplus
 extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "custom_conf.h"
#include "custom_errno.h"

/** @addtogroup BSP
  * @{
  */

/** @addtogroup CUSTOM
  * @{
  */

/** @defgroup CUSTOM_BUS CUSTOM BUS
  * @{
  */

/** @defgroup CUSTOM_BUS_Exported_Constants CUSTOM BUS Exported Constants
  * @{
  */

#define BUS_I2C3_INSTANCE I2C3
#define BUS_I2C3_SCL_GPIO_AF GPIO_AF4_I2C3
#define BUS_I2C3_SCL_GPIO_PIN GPIO_PIN_7
#define BUS_I2C3_SCL_GPIO_CLK_DISABLE() __HAL_RCC_GPIOH_CLK_DISABLE()
#define BUS_I2C3_SCL_GPIO_PORT GPIOH
#define BUS_I2C3_SCL_GPIO_CLK_ENABLE() __HAL_RCC_GPIOH_CLK_ENABLE()
#define BUS_I2C3_SDA_GPIO_CLK_ENABLE() __HAL_RCC_GPIOH_CLK_ENABLE()
#define BUS_I2C3_SDA_GPIO_PORT GPIOH
#define BUS_I2C3_SDA_GPIO_CLK_DISABLE() __HAL_RCC_GPIOH_CLK_DISABLE()
#define BUS_I2C3_SDA_GPIO_AF GPIO_AF4_I2C3
#define BUS_I2C3_SDA_GPIO_PIN GPIO_PIN_8

#ifndef BUS_I2C3_POLL_TIMEOUT
   #define BUS_I2C3_POLL_TIMEOUT                0x1000U
#endif
/* I2C3 Frequency in Hz  */
#ifndef BUS_I2C3_FREQUENCY
   #define BUS_I2C3_FREQUENCY  1000000U /* Frequency of I2Cn = 100 KHz*/
#endif

/**
  * @}
  */

/** @defgroup CUSTOM_BUS_Private_Types CUSTOM BUS Private types
  * @{
  */
#if (USE_HAL_I2C_REGISTER_CALLBACKS == 1U)
typedef struct
{
  pI2C_CallbackTypeDef  pMspInitCb;
  pI2C_CallbackTypeDef  pMspDeInitCb;
}BSP_I2C_Cb_t;
#endif /* (USE_HAL_I2C_REGISTER_CALLBACKS == 1U) */
/**
  * @}
  */

/** @defgroup CUSTOM_LOW_LEVEL_Exported_Variables LOW LEVEL Exported Constants
  * @{
  */

extern I2C_HandleTypeDef hi2c3;

/**
  * @}
  */

/** @addtogroup CUSTOM_BUS_Exported_Functions
  * @{
  */

/* BUS IO driver over I2C Peripheral */
HAL_StatusTypeDef MX_I2C3_Init(I2C_HandleTypeDef* hi2c);
int32_t BSP_I2C3_Init(void);
int32_t BSP_I2C3_DeInit(void);
int32_t BSP_I2C3_IsReady(uint16_t DevAddr, uint32_t Trials);
int32_t BSP_I2C3_WriteReg(uint16_t Addr, uint16_t Reg, uint8_t *pData, uint16_t Length);
int32_t BSP_I2C3_ReadReg(uint16_t Addr, uint16_t Reg, uint8_t *pData, uint16_t Length);
int32_t BSP_I2C3_WriteReg16(uint16_t Addr, uint16_t Reg, uint8_t *pData, uint16_t Length);
int32_t BSP_I2C3_ReadReg16(uint16_t Addr, uint16_t Reg, uint8_t *pData, uint16_t Length);
int32_t BSP_I2C3_Send(uint16_t DevAddr, uint8_t *pData, uint16_t Length);
int32_t BSP_I2C3_Recv(uint16_t DevAddr, uint8_t *pData, uint16_t Length);
int32_t BSP_I2C3_SendRecv(uint16_t DevAddr, uint8_t *pTxdata, uint8_t *pRxdata, uint16_t Length);
#if (USE_HAL_I2C_REGISTER_CALLBACKS == 1U)
int32_t BSP_I2C3_RegisterDefaultMspCallbacks (void);
int32_t BSP_I2C3_RegisterMspCallbacks (BSP_I2C_Cb_t *Callbacks);
#endif /* (USE_HAL_I2C_REGISTER_CALLBACKS == 1U) */

int32_t BSP_GetTick(void);

/**
  * @}
  */

/**
  * @}
  */

/**
  * @}
  */

/**
  * @}
  */
#ifdef __cplusplus
}
#endif

#endif /* CUSTOM_BUS_H */

