      SUBROUTINE MLNMIN(NU,NOMP01,NOMP02,NOMP03,NOMP04,NOMP05,
     %NOMP06,NOMP07,NOMP08,NOMP09,NOMP10,NOMP11,NOMP12,NOMP13,NOMP14,
     %NOMP15,NOMP16,NOMP17,NOMP18,NOMP19,NOMP20)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 07/01/2002   AUTEUR JFBHHUC C.ROSE 
C RESPONSABLE JFBHHUC C.ROSE
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR   
C (AT YOUR OPTION) ANY LATER VERSION.                                 
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT 
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF          
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU    
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                            
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE   
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,       
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C TOLE CRP_21
      IMPLICIT NONE
      CHARACTER*14 NU
      CHARACTER*24 NOMP01,NOMP02,NOMP03,NOMP04,NOMP05,
     %NOMP06,NOMP07,NOMP08,NOMP09,NOMP10,NOMP11,NOMP12,NOMP13,NOMP14,
     %NOMP15,NOMP16,NOMP17,NOMP18,NOMP19,NOMP20
       NOMP01  = NU(1:14)//'.MLTF.DESC'
       NOMP02  = NU(1:14)//'.MLTF.DIAG'
       NOMP03  = NU(1:14)//'.MLTF.ADRE'
       NOMP04  = NU(1:14)//'.MLTF.SUPN'
       NOMP05  = NU(1:14)//'.MLTF.PARE'
       NOMP06  = NU(1:14)//'.MLTF.FILS'
       NOMP07  = NU(1:14)//'.MLTF.FRER'
       NOMP08  = NU(1:14)//'.MLTF.LGSN'
       NOMP09  = NU(1:14)//'.MLTF.LFRN'
       NOMP10  = NU(1:14)//'.MLTF.NBAS'
       NOMP11  = NU(1:14)//'.MLTF.DEBF'
       NOMP12  = NU(1:14)//'.MLTF.DEFS'
       NOMP13  = NU(1:14)//'.MLTF.ADPI'
       NOMP14  = NU(1:14)//'.MLTF.ANCI'
       NOMP15  = NU(1:14)//'.MLTF.NBLI'
       NOMP16  = NU(1:14)//'.MLTF.LGBL'
       NOMP17  = NU(1:14)//'.MLTF.NCBL'
       NOMP18  = NU(1:14)//'.MLTF.DECA'
       NOMP19  = NU(1:14)//'.MLTF.NOUV'
       NOMP20  = NU(1:14)//'.MLTF.SEQU'
      END
