;; -*- mode: emacs-lisp; coding: hebrew-iso-8bit-unix -*-
;; hebeng.el --- simple Hebrew Latin mode with isearch support
;; Copyright (C) 1992-2003  Ehud karni <ehud@unix.mvs.co.il>

;; This file is NOT part of GNU Emacs, distribution conditions below.
;;
;;              EHUD   KARNI            ינרק   דוהא
;;              Ben Gurion st'   14   ןוירוג ןב 'חר
;;              Kfar - Sava    44 257     אבס - רפכ
;;              ===================================
;;              <kehud@iname.com>  972-(0)9-7659599
;;              ===================================

;;  RCS: $Id: hebeng.el,v 1.108 2003/04/24 13:14:33 ehud Exp ehud $
;;
;;  $Log: hebeng.el,v $
;;  Revision 1.108  2003/04/24 13:14:33  ehud
;;  Define constants: hebrew-mule-offset, unicode-LRM/-mule,
;;    unicode-RLM/-mule, hebrew-bidi-NP, unicode-LRM-as-str,
;;    unicode-RLM-as-str, unicode-ignore-chars
;;  New function: get-bidi-type, toggle-variable, auto-bidi-toggle,
;;    auto-bidi-auto-update, auto-bidi-add-embedding, auto-bidi-length,
;;    auto-bidi-add-char-to-strings-list, auto-bidi-set-state,
;;    hebrew-bidi-insert-LRM/RLM, winvert-list.
;;  Delete hebrew-kbd-on, hebrew-kbd-off.
;;  Modify hebrew-kbd-toggle, right2left-toggle (use of toggle-variable)
;;  Added new modified ekemacs functions: join-lines, kill-to-non-blank.
;;  New replacement for defuns from simple.el: newline-and-indent-ehud,
;;    open-line-ehud, split-line-ehud, open-split-line-ehud.
;;  Replace auto-R2L-add-char by auto-bidi-add-char, auto-R2L-back-char
;;    by auto-bidi-back-char.
;;
;;  Revision 1.107  2000/02/24  14:30:52  ehud
;;  Major changes to the logic of bidi handling. Easy entering of bidi
;;  text in both overwrite and insert mode, in L2R and R2L direction.
;;  The winvert-string improved, add winvert-encode-string.
;;
;;  Revision 1.106  2000/01/26  13:02:59  ehud
;;  Major rewrite of winvert-string, Added auto-R2L,
;;  Added isearch-yank-word/line (for prepending).
;;
;;  Revision 1.105  1998/03/15  16:58:51  ehud
;;  Last revision for 19.34
;;
;;  Revision 1.104  1996/02/19  10:55:06  ehud
;;  Emacs 19.30 version
;;
;;  Revision 1.103  1995/09/03  17:38:24  ehud
;;  isearch: Add isearch-yank-upto-blank (^B)
;;
;;  Revision 1.102  1995/08/28  12:50:17  ehud
;;  modifications for isearch: Hebrew keys & prepending of chars
;;
;;  Revision 1.101  1995/01/24  15:56:06  ehud
;;  1) minor fix for do-return (CR) at end-of-buffer
;;  2) move hebrew-syntax-word to here from ekemacs.el
;;
;;  Revision 1.100  1995/01/19  17:24:56  ehud
;;  SW initial version control for all el's

;;  This program is free software; you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation; either version 2 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program; if not, write to the Free Software
;;  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


;; The updated package can be got by email:
;;   Send email to:    auto_mail@unix.mvs.co.il.
;;   Subject: "files" (one word, no quotes).
;;   1st line of the content: "hebeng.el.gz" (one word, no quotes).
;;   The file will be then automatically sent to the reply address.
;;
;; For NTemacs on Hebrew enabled Windoz 9x/NT, You must work with Hebrew
;; font that is not inverted by the Windoz OS. I work with Web Hebrew
;; Monospace (TrueType fixed font). To get it:
;;   Send email to:    auto_mail@unix.mvs.co.il.
;;   Subject: "files" (one word, no quotes).
;;   1st line of the content: "wehm.ttf.gz" (one word, no quotes).


;; To work with this package load it and define keys of your choice to
;; the needed commands. Have a key assigned to `ins-toggle' (to stop
;; push mode) - usually the INSERT key.
;;
;; You should execute (display-hebrew "UNIX") if instead of Hebrew
;; glyphs you see \ooo (it means that emacs thinks the Hebrew
;; characters are not printable
;;
;;   Command                 Does                            My Key
;;   =======             ====================                ======
;; * hebrew-kbd-toggle   toggle Hebrew keyboard on/off       Alt-f1
;;   hebrew-kbd-all      Hebrew keyboard & R2L direction     Shift-Alt-f1
;;
;; * right2left-toggle   toggle right 2 left                 Alt-f2
;;   latin-kbd-all       Latin keyboard & L2R direction      Shift-Alt-f2
;;
;; * push-mode-set       start push mode (r2l & l2r)         Alt-f3
;;   auto-bidi-toggle    Toggle auto-bidi-on state           Shift-Alt-f3
;;
;;   display-hebrew      standard display table for Hebrew   Shift-Alt-H


;;    The following functions work in both L2R and R2L
;;
;; * ins-toggle    toggle insert mode / stop push mode       [insert]
;; * do-return     CR action: bol, end insert mode           ^M [enter]
;;
;; * back-space-ehud     back space action       my backspace key - "\177"
;;   clear-bol     Delete from beginning of line to point    Shift-HOME
;;   clear-eol     Delete/fill from point to end of line     Shift-END
;;   join-lines    Join this line with the next              Shift-F4
;;   kill-to-non-blank    Kills from current char up to      Alt-F9 / C-delete
;;                        first non blank (after blank)
;;   invert-line   Inverse line (right-left)                 Alt-I
;;
;; The functions marked with * are highly recommended to be assigned keys.


;;   MY function:                  Replaces:
;;
;;   self-insert-ehud              self-insert-command       (printables)
;;   beginning-of-line-ehud        beginning-of-line         C-a / [home]
;;   end-of-line-ehud              end-of-line               C-e / [end]
;;   delete-char-ehud              delete-char               C-d / [delete]
;;   newline-and-indent-ehud       newline-and-indent        C-j / [C-enter]
;;   open-line-ehud                open-line                 C-o
;;   split-line-ehud               split-line                M-C-o


;;   Bidi functions to be called alone or while entering bidi strings
;;
;;   winvert-line        Win inverse line (from Hebrew MS Windows) Alt-W
;;   winvert-encode-line Win inverse line (to Hebrew MS Windows)   Shift-Alt-W
;;  Note: The winvert functions deviate from the UNICODE TR#9 directions
;;        and are not fully compatible with Hebrew MS Windows 95/98.
;;
;;   hebrew-bidi-insert-LRM    insert L2R invisible char     Alt-L
;;   hebrew-bidi-insert-RLM    insert R2L invisible char     Alt-H
;;   auto-bidi-add-embedding   change embedding-level        Alt-E


;; Please note the variables:
;;   right2left-1st-col - The Hebrew default "width" for Home & CR.
;;   return-stops-ins - do-return (CR - ^M) stop insert mode if non-nil.
;;
;; The keys for enhancing the `isearch' are included in the package.
;;
;; There are also some command without keys that may be useful:
;;   invert-all-lines (&optional arg)
;;   winvert-all-lines (&optional arg)
;;   winvert-encode-all-lines (&optional arg)
;;   justify-in-cols (left-col right-col &optional left)
;;   justify-all-lines (left-col right-col &optional left)
;;   right2left-sort-lines (beg end reverse)


;;     TO DO
;;   =========
;;   The most needed (for text editing) is some fill function -
;;   `fill-paragraph-R2L' (see textmodes/fill.el).


;; Auxiliary variables and functions from other packages that are needed here

(defvar return-stops-ins nil
  "*do-return (CR - ^M - action) stop insert mode if non-nil.
 Set this variable to nil if you want `insert mode' to continue.")


(defun column-no (&optional arg)
 "returns column number of point or arg (char number if given)"
 (interactive "p")
       (save-excursion
           (if arg
               (goto-char arg))
           (let ((inhibit-field-text-motion))
               (1+  (- (point) (line-beginning-position))))))


(defun d-char (&optional arg) "delete char on this line only (NOT new line)"
  (interactive)
       (let ((char 1))
           (if arg
               (setq char arg))
           (while (and (> char 0) (not (eolp)))
               (delete-char 1)
               (setq char (1- char)))))

(defun forward-to-non-blank () "go to 1st non blank (after blank) to right"
 (interactive)
       (if (re-search-forward "[ \t\n][^ \t\n]" (point-max) t)
           (backward-char 1)))


(defun goto-col (arg &optional nospc)
  "goto ARG (column number) on current line, add spaces if needed
optional NOSPC means dont add spaces at end of line"
  (interactive "NGoto Column: ")
       (end-of-line)
       (let ((col-goto (- arg (column-no))))
           (if nospc ()
               (while (> col-goto 0)
                   (insert-char ?\040 1)
                   (setq col-goto (- col-goto 1))))
           (if (< col-goto 0)
               (goto-char (+ (point) col-goto)))))


(defun keymap-test (var)           ; internal function for keymap checking
       (and (boundp var)
            (keymapp (symbol-value var))))


(defun ins-mode () "Begin insert mode" (interactive)
       (setq overwrite-mode nil)
       (message "insert begin"))


(defun ins-toggle () "toggle insert mode with message" (interactive)
       (if overwrite-mode
           (ins-mode)
           (progn
               (ins-mode-end)
               (message "insert end")))
       (force-mode-line-update))


;; \340 - \373 = אבגדהוזחטיךכלםמןנסעףפץצקרשת

(defconst english-keyboard-chars (concat
       "\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037"
       " !\"#$%&'()*+,-./0123456789:;<=>?"
       "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
       "`abcdefghijklmnopqrstuvwxyz{|}~\177"
       "\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337"
     ;; אבגדהוזחטיךכלםמןנסעףפץצקרשת
       "tcdsvuzjyhlfkonibxg;p.mera,\373\374\375\376\377") "description of English keyboard on PC")

(defvar hebrew-keyboard-chars (concat
       "\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037"
     ;;                ,    . /             ;
       " !\"#$%&,()*+\372-\365.0123456789:\363<=>?"
       "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_"
     ;; `  a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p q  r   s   t   u   v w  x   y   z
       ";\371\360\341\342\367\353\362\351\357\347\354\352\366\356\355\364/\370\343\340\345\344'\361\350\346{|}~\177"
       "\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377") "description of Hebrew keyboard on PC")

(defvar hebrew-english-bidi-type (concat
       "--------- ----------------------"  ;; tab is of space type.
     ;;  !"#$%&'()*+,-./0123456789:;<=>?       "
       " AANNNBAIIANIBIBDDDDDDDDDDA-IAI-"
     ;; @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_
       "-LLLLLLLLLLLLLLLLLLLLLLLLLL---IB"
     ;; `abcdefghijklmnopqrstuvwxyz{|}~\177
       "ALLLLLLLLLLLLLLLLLLLLLLLLLL---A-"
     ;; אבגדהוזחטיךכלםמןנסעףפץצקרשת     S   (MsDOG Hebrew, Shift space)
       "RRRRRRRRRRRRRRRRRRRRRRRRRRR-----A---------------------------------------------------------------"
       "RRRRRRRRRRRRRRRRRRRRRRRRRRR--LR-")
"A string describing bidi reference for that character:
'R' for ALPHA Hebrew (RTL) character.  'L' for ALPHA Latin (LTR). 'D' - digit.
'N' - same as digit if NEAR (adjacent to) digit,
'I' - same as digit if between digits (INTER-DIGIT),
'A' same type as the ALPHA (R or L type) if near ALPHA, 'I' otherwise.
   If between R & L ALPHA, same as the previous (leftside) ALPHA
'B' same as the ALPHA if near ALPHA, 'N' otherwise.
other - neutral (replacement when in Hebrew string)" )

(defconst hebrew-english-bidi-rep (concat
       "\000\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037"
       " !\"#$%&')(*+,-./0123456789:;>=<?"
       "@ABCDEFGHIJKLMNOPQRSTUVWXYZ]\\[^_"
       "`abcdefghijklmnopqrstuvwxyz}|{~\177"
       "\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237 \241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377") "replacment characters for bidi Hebrew")

(defvar hebrew-english-bidi-num-2-latin "\\(L[I ]?D+\\)\\|\\(D+[I ]?L\\)"
  "A regexp for converting digits after Latin to be treated like Latin.
Possible values and their meaning:
  \"X\"   - do not do any conversion.
  \"LD+\" - do conversion only for digits which are adjacent to Latin.
  \"L[ ]?D+\"  - allow maximum of 1 intervening space.
  \"L[I ]?D+\" - allow maximum of 1 intervening space or punctuation.
  \"L[ ]*D+\"  - any number of spaces (UNICODE TR#9, MS Hebrew Windoz).
  \"\(L[I ]?D+\)\|\(D+[I ]?L\)\" - my preferred setting (based on Eli Zaretskii suggestion)
                           Any number with only 1 intervening `I' or `A'.
See `hebrew-english-bidi-type' for character types.")


(defconst Alef-Unix 224 "Place of Alef (Hebrew 1st letter) on UNIX system")
(defconst hebrew-mule-offset (- ?א Alef-Unix) "Offset of Hebrew in mule represntation form ISO-8859-8 (8 bits Hebrew)")

(defconst unicode-LRM  ?\375 "The UNICODE LRM (Left-to-Right Mark - zero width character)")
(defconst unicode-LRM-mule (+ unicode-LRM hebrew-mule-offset)
                           "The UNICODE LRM (Left-to-Right Mark) in mule represntation")
(defconst unicode-RLM  ?\376 "The UNICODE RLM (Right-to-Left Mark - zero width character)")
(defconst unicode-RLM-mule (+ unicode-RLM hebrew-mule-offset)
                           "The UNICODE LRM (Left-to-Right Mark) in mule represntation")
(defconst hebrew-bidi-NP ?\377
      "Non printable used in bidi processing, must not come from user input")
(defconst unicode-LRM-as-str (char-to-string unicode-LRM) "The UNICODE LRM as string")
(defconst unicode-RLM-as-str (char-to-string unicode-RLM) "The UNICODE RLM as string")
(defconst unicode-ignore-chars (concat unicode-LRM-as-str
                                       unicode-RLM-as-str
                                       (char-to-string hebrew-bidi-NP))
  "string of unicode chars to be ignored after bidi conversion")

(defvar Alef-is 224 "The Alef (Hebrew 1st letter) on this system (PC=128, Windows/Unix=224)")
(defvar Tav-is  250 "The Tav (Hebrew last letter) on this system = Alef + 26")

(defvar last-input-ehud nil "Last input character for Hebrew keyboard support")

(defvar hebrew-on nil "Hebrew chars switch. non nil = Hebrew is on")
(setq-default hebrew-on nil)
(make-variable-buffer-local 'hebrew-on)

(defvar push-mode-on nil "Push chars switch. non nil = push mode is on")
(setq-default push-mode-on nil)
(make-variable-buffer-local 'push-mode-on)

(defvar auto-bidi-on nil "Auto bidi chars switch. non nil = auto bidi mode is on.
In auto bidi mode entering Hebrew characters in LTR mode does add it in right to
left (overwrite or push, depending on the overwrite mode). The same is done for
 Latin and numerals in RTL. See `hebrew-english-bidi-type' variable.")
(setq-default auto-bidi-on nil)
(make-variable-buffer-local 'auto-bidi-on)

(defvar auto-bidi-lower nil
  "Auto bidi lower-case switch. Non nil means treat lower-case as Hebrew. When
nil treat only real Hebrew characters as Hebrew. See `auto-bidi-on' variable.")
(setq-default auto-bidi-lower nil)
(make-variable-buffer-local 'auto-bidi-lower)

(defvar auto-bidi-params '(-1 -1 (""))
  "Auto bidi parameters - last position, reference position, list of bidi strings.
If you value your Emacs editing you'll will not touch this variable.")
(setq-default auto-bidi-params '(-1 -1 ("")))
(make-variable-buffer-local 'auto-bidi-params)

(defvar auto-bidi-state nil "Auto bidi mode line description")
(setq-default auto-bidi-state nil)
(make-variable-buffer-local 'auto-bidi-state)

(defvar right2left-on nil
 "Right to left direction switch. non nil = write chars from right to left")
(setq-default right2left-on nil)
(make-variable-buffer-local 'right2left-on)

(defvar right2left-1st-col 80 "Right to left first column value (default=80).
 This is the Home column for right to left movment")
(setq-default right2left-1st-col 80)
(make-variable-buffer-local 'right2left-1st-col)

(defun get-bidi-type (char)
  "Return the bidi type of the given CHAR.
It may be A, B, D, I, L, N, R, space or -.
See help for `hebrew-english-bidi-type'."
       (if (< char 256)
           (if (and auto-bidi-lower
                    (>= char ?a)                       ;; a-z range only
                    (<= char ?z))
               ?R                                      ;; Lower case is Hebrew
               (aref hebrew-english-bidi-type char))   ;; normal 8 bit char
           (if (or (< char ?\xC00)                 ;; Hebrew MULE start
                   (> char ?\xC7F))                ;; Hebrew MULE end
               ?L                                  ;; Not Hebrew, Assume Latin (any kind)
               (aref hebrew-english-bidi-type (- char hebrew-mule-offset)))))  ;; Hebrew Range C60 -> E0

(defun display-hebrew (&optional unix-dos)
  "change standard display tab for Hebrew. An optional parameter UNIX-DOS
may be \"UNIX\" (Hebrew in 224-250) or \"DOS\" (Hebrew in 128-154).
Any value which is not \"dos\" or \"DOS\" is UNIX (and WINDOZ)."
       (interactive "sselect operating system (UNIX or DOS): ")
       (if (not unix-dos)
           (setq unix-dos "UNIX"))
       (setq Alef-is (if (string-equal (upcase unix-dos) "DOS")
                         (- 352 Alef-Unix) Alef-Unix ))
       (setq Tav-is (+ Alef-is 26))                    ;; Tav in this keyboard
       (let* ((beg (- 352 Alef-is))                    ;; beginning of other Hebrew
              (dif (- beg Alef-is))                    ;; difference between the 2 Hebrews
              (heb-strt (if window-system              ;; use different values for X/w32 and TTY
                   (+ Alef-Unix hebrew-mule-offset) Alef-Unix))    ;; X-hebrew-mule TTY-E0
              (cnt 27)                                 ;; UNIX/WINDOWS  - Hebrew in 0xE0-0xFA (224-250)
              (alef beg)                               ;; other alef
              (tav  (+ Tav-is dif))                    ;; other tav
              (unix-128-beg  128)                      ;; 0x080 - start of right half (128-255)
              (heb-prfx (if window-system              ;; use different prefix for X
                            172 169))                  ;; PC, TTY = 169, real X=172
              (heb heb-strt))                          ;; start with hebrew-start

           (or standard-display-table
               (setq standard-display-table (make-display-table)))
           (standard-display-8bit 127 254)

           (while (> cnt 0)
               (aset standard-display-table (- beg dif) (vector heb))
               (aset standard-display-table beg (vector heb-prfx heb))
               (aset standard-display-table (+ (- beg dif) hebrew-mule-offset) (vector heb))
               (setq heb (1+ heb))
               (setq beg (1+ beg))
               (setq cnt (1- cnt)))
           (aset standard-display-table 160 (vector heb-prfx heb-prfx))
           (aset standard-display-table (+ 160 hebrew-mule-offset) (vector heb-prfx heb-prfx))   ;; mule

           (setq cnt (length hebrew-keyboard-chars))   ;Hebrew keyboard table (255)
           (while (> cnt 0)
               (setq cnt (1- cnt))
               (setq heb (aref hebrew-keyboard-chars cnt))
               (and (>= heb alef)                      ;requested Hebrew (א)
                    (<= heb tav)                       ;requested Hebrew Tav (ת)
                    (aset hebrew-keyboard-chars cnt (- heb dif))))

           (setq cnt 127)
           (or window-system                           ;don't do for real window system
               (while (> cnt 32)                       ;do for MS-DOS & TTY
                   (aset standard-display-table (+ unix-128-beg hebrew-mule-offset cnt)
                         (aref standard-display-table (+ unix-128-beg cnt)))
                   (setq cnt (1- cnt))))
           ))

;; (set-fontset-font "-*-*-*-*-*-*-*-*-*-*-*-*-fontset-default" 'hebrew-iso8859-8 "-misc-fixed-medium-r-normal--13-120-75-75-c-80-iso8859-8")


(defun toggle-variable (var arg)
  "Toggle VAR state (t --> nil,  nil-->t). When ARG is non nil,
toggle if non number or 0, set to t on positive, nil on negative.
e.g. to toggle foo: (toggle-variable 'foo nil)
     to unset  foo: (toggle-variable 'foo -1)"
       (if (and arg
               (numberp arg)
               (not (zerop arg)))
           (set var (> arg 0))
           (set var (not (symbol-value var)))))

(defun right2left-toggle (&optional arg)
 "Toggle between directions left to right (normal) and right to left (Hebrew)
 (see `toggle-variable' help for calling options)."
      (interactive "P")
       (toggle-variable 'right2left-on arg))

(defun auto-bidi-toggle (&optional arg)
  "Toggle/set/unset auto-bidi-on state (see `toggle-variable' help)."
  (interactive "P")
       (toggle-variable 'auto-bidi-on arg))

(defun auto-bidi-lower-toggle (&optional arg)
  "Toggle/set/unset auto-bidi-lower state (see `toggle-variable' help)."
  (interactive "P")
       (toggle-variable 'auto-bidi-lower arg))

(defun hebrew-kbd-toggle (&optional arg)
  "Toggle Hebrew keyboard state (see `toggle-variable' help)."
  (interactive "P")
       (toggle-variable 'hebrew-on arg))

(defun auto-bidi-auto-update ()
  "Clear `auto-bidi-params' and `auto-bidi-state' if not within auto-bidi."
       (and auto-bidi-on
            (/= (point) (car auto-bidi-params))
            (setq auto-bidi-params '(-1 -1 (""))
                 auto-bidi-state (format " %sbidi--"
                               (if auto-bidi-lower "L-" "")))))

(add-hook 'post-command-hook 'auto-bidi-auto-update)


(defun hebrew-kbd-all () "Signal Hebrew keyboard on & direction right to left"
  (interactive)
       (setq hebrew-on t)
       (setq right2left-on t))

(defun latin-kbd-all () "Signal Hebrew keyboard off & direction left to right"
  (interactive)
       (setq hebrew-on nil)
       (setq right2left-on nil))

(defun push-mode-set () "Start push mode (insert in reverse direction)
works both in r2l & l2r, toggle Hebrew state. Stop by pressing Insert"
  (interactive)
       (if (not push-mode-on)
           (progn
               (message "push mode begin")
               (setq push-mode-on t)
               (setq overwrite-mode nil)
               (hebrew-kbd-toggle))))


;; redefines defuns from ekemacs

(defun ins-mode-end () "End insert mode (stop push mode if active)"
  (interactive)
       (setq overwrite-mode overwrite-mode-textual)
       (if push-mode-on
           (progn
               (setq push-mode-on nil)
               (hebrew-kbd-toggle))))

(defun do-return ()
  "CR action: end insert mode (if return-stops-ins is non nil)
 go to 1st char (left or right) of next line"
       (interactive)
       (if return-stops-ins
           (ins-mode-end))
       (next-line-home-ehud))

(defun join-lines ()
 "Join this line with the next with exactly 1 space between them after joining"
  (interactive "*")
       (if (not right2left-on)
           (progn
               (end-of-line)
               (delete-char 1)
               (just-one-space))
           (let (pos col str beg end)
               (beginning-of-line)
               (skip-chars-forward " \t")
               (setq pos (point))
               (setq col (column-no))
               (forward-line 1)
               (skip-chars-forward " \t")
               (setq beg (point))
               (end-of-line)
               (setq end (point))
               (skip-chars-backward " \t")
               (setq str (buffer-substring beg (point)))
               (beginning-of-line)
               (backward-char 1)
               (delete-region (point) end)
               (goto-char pos)
               (beginning-of-line)
               (delete-region (point) pos)
               (setq col (- col (length str) 2))
               (if (< col 0)
                   (setq col 0))
               (insert (make-string col ? )
                       str " "))))

(defun kill-to-non-blank ()
  "kill to 1st non blank (after blank) to right (or left in R2L mode)"
  (interactive "*")
       (if (not right2left-on)
           (kill-region (point) (progn (forward-to-non-blank) (point)))    ; normal (L2R)
           (let ((pos (- 0 (point)))
                 beg end nxt lng nlns)
               (beginning-of-line)
               (setq beg (point))                          ;;left 1st line
               (invert-line 0)                             ;;reverse it
               (end-of-line)
               (setq end (1- (point)))                     ;;right 1st line
               (setq lng (- end beg -1))                   ;; original line length
               (setq pos (+ beg end pos))                  ;;original reversed pos
               (goto-char pos)
               (forward-to-non-blank)                      ;;next non blank
               (setq nxt (point))
               (if (search-backward "\n" pos t)            ;;check if same line)
                   (progn
                       (goto-char nxt)
                       (invert-line 0)
                       (goto-char pos)
                       (forward-to-non-blank)
                       (setq nxt (point))))
               (kill-region pos nxt)                       ;; kill (reversed)
               (end-of-line)
               (setq nxt (point))                          ;; end of combined line
               (setq nxt (% (- nxt beg) lng))
               (if (/= nxt 0)
                   (insert (make-string (- lng nxt) ? )))  ;; complete to full lines
               (setq nlns (/ (- pos beg) lng))             ;; no. of lines before pos
               (setq pos (- (+ beg beg nlns (* 2 nlns lng) lng) pos 1))
               (setq end (+ beg lng))                      ;; start of line + 1
               (while (< end nxt)                          ;; do for all sub lines
                   (goto-char end)
                   (insert "\n")
                   (setq end (+ end lng)))
               (save-restriction
                   (narrow-to-region beg end)
                   (invert-all-lines))
               (goto-char pos))))


;; replacement for defuns from simple.el

(defun newline-and-indent-ehud ()
 "Extension of simple.el `newline-and-indent' for R2L."
       (interactive "*")
       (if (not right2left-on)
           (newline-and-indent)            ;; L2R mode
           (let ((pos (point))
                 end rcol)
               (skip-chars-backward " \t")
               (setq end (point))
               (end-of-line)
               (skip-chars-backward " \t")
               (setq rcol (column-no))
               (if (looking-at "[ \t\n]")
                   (setq rcol (1- rcol)))
               (if (< rcol 2)
                   (setq rcol right2left-1st-col))
               (goto-char end)
               (open-split-line-ehud rcol 1)
               (goto-char pos)))
       (setq auto-bidi-params '(-1 -1 (""))))  ;; NO auto bidi !


(defun open-line-ehud (arg)
 "Extension of simple.el `open-line' for R2L."
  (interactive "*p")
       (if right2left-on
           (open-split-line-ehud right2left-1st-col arg)
           (open-line arg)))

(defun split-line-ehud ()
 "Extension of simple.el `split-line' for R2L."
  (interactive "*")
       (if right2left-on
           (open-split-line-ehud nil 1)
           (split-line)))

(defun open-split-line-ehud (ops lns)
 "Internal function for open/split line in R2L (checked before calling)
OPS-nil for split, right column for open, LNS-no. of line to add.
called from `newline-and-indent-ehud' with the needed right-column."
       (let ((pos (point))                     ; save for restoring point
             str lng rcol)                     ; string to copy, its length, requested right col
           (beginning-of-line)
           (setq str (buffer-substring (point) (1+ pos)))  ; string to move
           (setq lng (length str))             ; actual string length
           (delete-region (point) (1+ pos))
           (insert (make-string lng ? ))       ; replace by spaces
           (while (> lns 0)                    ; for the number of lines requested
               (end-of-line)
               (insert "\n")
               (beginning-of-line-ehud)        ; add a line with spaces
               (setq lns (1- lns)))            ; 1 line less
           (setq rcol (or ops right2left-1st-col)) ;ensure rcol setting
           (setq lng (min lng rcol))               ;string length, but not exceeding line length
           (goto-col (1+ rcol))                    ;ensure spaces if rcol > right2left-1st-col
           (goto-col (if ops (- rcol lng -1) 1))   ;left col for the moved string
           (delete-region (point) (+ (point) lng ))
           (insert str)                            ; replace spaces by the moved string
           (goto-char pos)))                   ; restore original position


(defun next-line-home-ehud ()
  "Go to 1st char (left or right) of next line, if on last line, create empty one."
       (or (search-forward "\n" nil 1)
           (insert "\n"))
       (beginning-of-line-ehud))


(defun hebrew-bidi-insert-LRM (arg)
"Insert (overwrite) UNICODE LRM character"
  (interactive "p")
       (setq last-input-char unicode-LRM)
       (self-insert-ehud arg))

(defun hebrew-bidi-insert-RLM (arg)
"Insert (overwrite) UNICODE RLM character"
  (interactive "p")
       (setq last-input-char unicode-RLM)
       (self-insert-ehud arg))


(defun self-insert-ehud (arg)
"Insert (overwrite) keyd character according to keyboard mode (Hebrew/Latine)"
  (interactive "p")
       (let* ((tck (this-single-command-keys))
              (lng (length tck)))
           (setq last-input-ehud (multibyte-char-to-unibyte (aref tck (1- lng)))))
       (if hebrew-on
           (setq last-input-ehud (aref hebrew-keyboard-chars last-input-ehud)))
       (while (> arg 1)
           (self-insert-ehud-one)
           (setq arg (1- arg)))
       (self-insert-ehud-one))


(defun self-insert-ehud-one ()
  "Insert (overwrite) one character according to direction (L2R or R2L)"
       (if auto-bidi-on
           (progn
               (if (/= (point) (car auto-bidi-params))
                   (setq auto-bidi-params (list (point) (point) '(""))))
               (auto-bidi-add-char)
               (auto-bidi-set-state))
           (self-insert-ehud-one-normal)))


(defun self-insert-ehud-one-normal ()
       (setq auto-bidi-params '(-1 -1 ("")))   ;; NO auto bidi !
       (if right2left-on
           (let ((last-input-multi (unibyte-char-to-multibyte last-input-ehud)))
               (if (eolp)
                   (if (bolp)
                       (progn
                           (insert-char last-input-multi 1)
                           (beginning-of-line))
                       (progn
                           (insert-char ?  1)
                           (insert-char last-input-multi 1)
                           (backward-char 2)
                           (and overwrite-mode
                               (self-insert-ehud-one-r2l-ins))))
                   (progn
                       (forward-char 1)
                       (insert-char last-input-multi 1)
                       (backward-char 2)
                       (if overwrite-mode
                           (progn
                               (d-char 1)
                               (if (bolp)
                                   (next-line-home-ehud)
                                   (backward-char 1)))
                           (self-insert-ehud-one-r2l-ins)))))
           (let ((last-command-event last-input-ehud))
               (self-insert-command 1)
               (if push-mode-on
                   (backward-char 1)))))

(defun self-insert-ehud-one-r2l-ins ()
  "Insert/overwrite one character in right 2 left direction"
       (save-excursion
           (beginning-of-line)
           (delete-char 1))
       (and push-mode-on
           (not (bolp))
           (forward-char 1)))

(defun auto-bidi-add-char ()
  "Add 1 character in bidi mode, always add as last (rightmost) to logical input.
Check the `auto-bidi-params' variable.
All input is strictly 8 bits (even in mule) !"
       (let* ((ref (nth 1 auto-bidi-params))    ;; refrefence char
              (lstr (nth 2 auto-bidi-params))   ;; keyboard input as list of strings
             Tstr ofst lng col)
           (aset hebrew-english-bidi-type hebrew-bidi-NP
                 (get-bidi-type last-input-ehud))
           (setq Tstr (winvert-list (auto-bidi-add-char-to-strings-list
                                         lstr hebrew-bidi-NP) 'no-rep))
           (setq ofst (string-match (char-to-string hebrew-bidi-NP) Tstr))
           (if (string-match (regexp-quote (char-to-string last-input-ehud)) unicode-ignore-chars)
               (setq Tstr (concat (substring Tstr 0 ofst)  ;; don't put the LRM or RLM char
                                  (substring Tstr (1+ ofst))))
               (aset Tstr ofst (if (= last-input-ehud ?\240)
                                   ?  last-input-ehud)))   ;; put the real input instead of the hebrew-bidi-NP)
           (setq lng (1- (length Tstr)))
           (if overwrite-mode
               (setq lng (1+ lng)))
           (if right2left-on
               (progn
                   (setq col (- (column-no ref) lng))
                   (if overwrite-mode
                       (setq col (1+ col))
                       (progn
                           (goto-col 1)
                           (d-char 1)))
                   (goto-col (max 1 col))
                   (d-char lng)
                   (insert-string Tstr)
                   (if (= col 1)
                       (progn
                           (next-line-home-ehud)
                           (setq auto-bidi-params '(-1 -1 ("")))
                           (setq ref -1))
                       (goto-col (+ col ofst -1))))
               (progn
                   (goto-char ref)
                   (d-char lng)
                   (insert-string Tstr)
                   (goto-char (+ ref ofst))
                   (and (numberp last-input-char)
                       (= last-input-char last-input-ehud)
                       (let ((overwrite-mode overwrite-mode-textual)
                             (last-command-event last-input-ehud))
                           (self-insert-command 1)))
                   (goto-char (+ ref ofst 1))))
           (if (> ref 0)
               (setq auto-bidi-params
                     (list (point) ref (auto-bidi-add-char-to-strings-list lstr last-input-ehud))))))


(defun auto-bidi-add-embedding ()
  "Add embedding level to current entered string."
       (interactive)
       (if (/= (point) (car auto-bidi-params))                     ;no auto add in effect
           (setq auto-bidi-params (list (point) (point) '(""))))   ;make it effective
       (setq auto-bidi-params (list
           (nth 0 auto-bidi-params)
           (nth 1 auto-bidi-params)
           (append (nth 2 auto-bidi-params) (list ""))))
       (auto-bidi-set-state))


(defun auto-bidi-add-char-to-strings-list (lstr char)
  "Add, to the last string in the list of strings LSTR, one CHAR"
       (let* ((rvlst (reverse lstr))
              (str (concat (car rvlst) (char-to-string char))))
           (append (reverse (cdr rvlst)) (list str))))

(defun auto-bidi-length (LSTR)
  "Find total length of all the strings in list of strings."
       (length (mapconcat 'identity LSTR "")))

(defun auto-bidi-set-state ()
  "compute bidi state for mode line"
  (setq auto-bidi-state (format " %sbidi[%d,%d]"
                               (if auto-bidi-lower "L-" "")
                               (auto-bidi-length (nth 2 auto-bidi-params))
                               (1- (length (nth 2 auto-bidi-params))))))

(defun auto-bidi-back-char (arg)
       (let* ((ref (nth 1 auto-bidi-params))
              (lstr (nth 2 auto-bidi-params))
              (rstr (reverse lstr))
              (lng (auto-bidi-length lstr))
              (dlng (length (winvert-list lstr 'no-rep)))
              (dcnt (if (< arg lng) arg lng))      ;;number of chars to delete from saved input string
              col last-input-ehud)
           (if (< arg lng)
               (progn
                   (setq dcnt arg)
                   (while (> dcnt 0)
                       (setq arg (length (car rstr)))
                       (if (> arg dcnt)
                           (setq rstr
                                 (append (list (substring (car rstr) 0 (- 0 dcnt)))
                                         (cdr rstr)))
                           (setq rstr (cdr rstr)))
                       (setq dcnt (- dcnt arg)))
                   (setq lstr (reverse rstr))
                   (setq arg -1))
               (progn
                   (setq dcnt lng)
                   (setq arg (- arg lng))
                   (setq lstr '(""))))
           (setq dlng (- dlng (length (winvert-list lstr 'no-rep))))
           (if (> arg 0)                           ;;write string not empty
               (setq dlng (1+ dlng)))              ;;delete length from visual line
           (and overwrite-mode
                (> dlng 1)
                (setq dlng (1- dlng)))
           (if right2left-on
               (progn
                   (setq col (- (column-no ref) lng))
                   (setq col (1+ col))
                   (goto-col col)
                   (d-char dlng)
                   (goto-col 1)
                   (insert (make-string dlng ? ))
                   (goto-char ref))
               (progn
                   (goto-char ref)
                   (or overwrite-mode
                        (zerop arg)
                        (setq dlng (1+ dlng)))
                   (d-char dlng)))
           (if (< arg 0)
               (progn
                   (while (string-equal (car rstr) "")
                       (setq rstr (cdr rstr)))
                   (setq arg (car rstr))
                   (setq last-input-ehud (aref (substring arg -1) 0))
                   (setq auto-bidi-params
                         (list (point) ref (reverse
                                               (append (list (substring arg 0 -1))
                                                       (cdr rstr)))))
                   (auto-bidi-add-char))
               (progn
                   (setq auto-bidi-params '(-1 -1 ("")))
                   (setq arg (- arg dcnt))
                   (if (> arg 0)
                       (back-space-ehud-normal arg))))))


(defun back-space-ehud (arg)
  "Delete (back space) one character according to direction & mode"
  (interactive "p")
       (or arg (setq arg 1))
       (if (and auto-bidi-on
                (= (point) (car auto-bidi-params)))
           (auto-bidi-back-char arg)
           (back-space-ehud-normal arg))
       (auto-bidi-set-state))

(defun back-space-ehud-normal (arg)
  "Delete (back space) one character according to direction & mode (not auto-bidi)."
       (if push-mode-on
           (delete-char-ehud arg)
           (progn
               (if right2left-on
                   (progn
                       (forward-char 1)
                       (save-excursion
                           (beginning-of-line)
                           (insert-char ?  arg))
                       (if arg
                           (delete-char arg t)
                           (delete-char 1))
                       (backward-char 1))
                   (if (bobp)
                       (beep)
                       (let ((overwrite-mode))
                           (if arg
                               (backward-delete-char-untabify
                                                 (min arg (1- (point))) t)
                               (backward-delete-char-untabify 1)))))
               )))


(defun delete-char-ehud (arg)
  "Delete one (arg) character according to direction"
  (interactive "p")
       (if right2left-on
           (if (bolp)
               (progn
                   (delete-char 1)
                   (insert-char ?  1)
                   (backward-char 1))
               (progn
                   (save-excursion
                       (beginning-of-line)
                       (insert-char ?  arg))
                   (if (eolp)
                       (insert-char ?  1)
                       (forward-char 1))
                   (let ((overwrite-mode))
                       (if arg
                           (backward-delete-char-untabify arg t)
                           (backward-delete-char-untabify 1)))
                   (backward-char 1)))
           (if (eobp)
               (beep)
               (if arg
                   (delete-char (min arg (- (point-max) (point))) t)
                   (delete-char 1))))
       (and auto-bidi-on
            (setq auto-bidi-params '(-1 -1 ("")))   ;; NO auto bidi !
            (auto-bidi-set-state)))


(defun beginning-of-line-ehud ()
  "Go to beginning of line according to direction" (interactive)
       (if right2left-on
           (progn
               (goto-col (1+ right2left-1st-col))
               (goto-col right2left-1st-col))
           (beginning-of-line)))

(defun end-of-line-ehud ()
  "Go to end of line according to direction" (interactive)
       (if right2left-on
           (let (fnd
                 (eol (progn (end-of-line) (point))))
               (beginning-of-line)
               (setq fnd (re-search-forward "[^ \t^n]" eol 1))
               (and (not (bolp))
                    (or (backward-char 1) t)
                    fnd
                    (not (bolp))
                    (backward-char 1)))
;;         (if position-col-var
;;             (end-of-line)
;;             (to-last-non-blank))))
           (end-of-line)))


(defun clear-bol ()
  "Delete/fill from beginning of line to point according to direction"
  (interactive)
       (let ((save-point (point))
             ins-cnt)
           (beginning-of-line-ehud)
           (if right2left-on
               (progn
                   (setq ins-cnt (- (point) save-point))
                   (delete-region (1+ save-point) (1+ (point)))
                   (beginning-of-line)
                   (insert (make-string (max 0 ins-cnt) ? ))
                   (beginning-of-line-ehud))
               (kill-region save-point (point)))))

(defun clear-eol ()
  "Delete/fill from point to end of line according to direction" (interactive)
       (let ((save-point (point)))
           (end-of-line-ehud)
           (if (/= save-point (point))
               (if right2left-on
                   (let ((lng (- save-point (point) -1)))
                       (insert (make-string lng ? ))
                       (kill-region (point) (+ (point) lng)))
                   (kill-region save-point (point))))
           (goto-char save-point)))


;;---------------- invert (right to left) -------------------

(defun invert-line (&optional arg)
"Inverse line (right-left) if arg given, inverse arg chars"
  (interactive "p")
       (let* ((pos (point))
              (eos (progn (if (< arg 2)
                              (end-of-line) (goto-col (1+ arg)))
                          (point)))
              (str (buffer-substring (progn (beginning-of-line) (point)) eos)))
           (insert-string (invert-string str))
           (delete-char (length str))
           (goto-char pos)))


(defun invert-all-lines (&optional arg)
"Invert (right-left) all the lines in the buffer,
if arg given, inverse arg charcters in each lines"
  (interactive "p")
       (goto-char (point-min))
       (let* ((eol 0)
              (bol 0)
              (str ""))
           (while (not (eobp))
               (setq bol (point))
               (end-of-line)
               (if arg
                   (goto-col (1+ arg))
                   (end-of-line))
               (setq eol (point))
               (setq str (buffer-substring bol eol))
               (delete-region bol eol)
               (insert-string (invert-string str))
               (forward-line 1))))


(defun invert-string (STR)
"Invert STRING (right-left) of any length"
       (let ((lix 0)                   ;left index
             (rix (1- (length STR)))   ;right index
             lc rc)                    ;left, right char
           (while (< lix rix)
               (setq lc (aref STR lix))
               (setq rc (aref STR rix))
               (aset STR lix rc)
               (aset STR rix lc)
               (setq rix (1- rix))
               (setq lix (1+ lix)))
           STR))


;;---------------- winvert (right to left for Hebrew MS Windows) -------------------


(defun winvert-line (&optional arg)
"Win inverse line (right-left for Hebrew MS Windows)
if ARG given, inverse arg chars"
  (interactive "p")
       (let* ((pos (point))
              (eos (progn (if (< arg 2)
                              (end-of-line) (goto-col (1+ arg))) (point)))
              (str (buffer-substring (progn (beginning-of-line) (point)) eos)))
           (insert-string (winvert-string str))
           (delete-char (length str))
           (goto-char pos)))


(defun winvert-all-lines (&optional arg)
"Win invert (right-left for Hebrew MS Windows) all the lines in the buffer,
if ARG given, inverse the left (first) arg charcters in each line."
  (interactive "p")
       (goto-char (point-min))
       (let* ((eol 0)
              (bol 0)
              (str ""))
           (while (not (eobp))
               (setq bol (point))
               (end-of-line)
               (if arg
                   (goto-col arg)
                   (end-of-line))
               (setq eol (point))
               (setq str (buffer-substring bol eol))
               (delete-region bol eol)
               (insert-string (winvert-string str))
               (forward-line 1))))


(defun winvert-string (STR &optional NO-REP Sspc)
"Invert STRING (right-left for Hebrew MS Windows) of any length.
The steps taken are according to Unicode TR9 (implicit bidi)
Optional NO-REP - do not replace with value from `hebrew-english-bidi-rep'.
Optional Sspc   - change Shift Space (0xA0) to space (0x20)
Assume reading direction according to `right2left-on': nil-L2R else R2L."
       (let* ((ix  0)                          ;string index
              (Nbn (if right2left-on ?R ?L))   ;netural boundry type
              (S1st 0)                         ;Strong first
              (Last -1)                        ;Strong last (same type as 1st)
              (Styp Nbn)                       ;Strong type
              (isub "")                        ;temp string
              (wstr "")                        ;winverted string
              ct len typs)                     ;character type (R, L, other), string length, types string
           (setq STR (concat STR               ;add strong RtL+LtR/LtR+RtL terminator
                   (if right2left-on           ;must be according to direction
                       (vector unicode-RLM unicode-LRM)    ;R2L - RLM+LRM
                       (vector unicode-LRM unicode-RLM)))) ;L2R - LRM+RLM
           (setq typs (winvert-types STR))     ;create string of the types of STR
           (setq len (length STR))             ;string length
           (while (< ix len)
               (setq ct (aref typs ix))
               (if (or (= ct ?L)               ;ignore neutrals
                       (= ct ?R))              ;and digits
                   (if (= Styp ct)             ;same as last strong type
                       (setq Last ix)          ;yes, last strong position
                       (progn                  ;(only for documentation)
                           (if (= Nbn Styp)    ;for boundry neutrals
                               (setq Last (1- ix)))
                           (setq isub (substring STR S1st (1+ Last)))  ;;sub string to convert
                           (setq isub (if (= Styp ?R)                  ;;R-R2L (Hebrew) else L-Latin
                                   (winvert-string-hebrew isub         ;; Hebrew with types sub string
                                       (substring typs S1st (1+ Last)) NO-REP)
                                   (winvert-string-latin isub)))
                           (setq wstr (if right2left-on           ;Winvert R2L or L2R
                                          (concat isub wstr)      ;add on the left
                                          (concat wstr isub)))    ;add on the right
                           (setq S1st (1+ Last))   ;next Strong first
                           (setq Last ix)          ;Strong last
                           (setq Styp ct))))       ;Strong type
               (setq ix (1+ ix)))
           (and Sspc
                (while (string-match "\240" wstr)
                   (aset wstr (match-beginning 0) ? )))
           wstr))


(defun winvert-list (LSTR &optional NO-REP)
  "Winvert a list of strings and concatenate the results.
Negate the right2left-on between successive strings."
       (let ((right2left-on right2left-on) ;; will change within the function
             (rslt ""))
           (while LSTR
               (setq rslt (concat rslt (winvert-string (car LSTR) NO-REP 'Sspc)))
               (setq right2left-on (not right2left-on))
               (setq LSTR (cdr LSTR)))
           rslt))


(defun winvert-string-latin (STR)
"Windoz Invert Latin STRING (only Latin, neutrals and digits)."
       (let* ((ix 0)                       ;string index
              (len (length STR))           ;string length
              (istr "")                    ;inverted string
              ic)
           (while (< ix len)
               (setq ic (aref STR ix))
               (or (= ic unicode-LRM)
                   (= ic unicode-LRM-mule)
                   (setq istr (concat istr (vector ic))))
               (setq ix (1+ ix)))
           istr))

(defun winvert-string-hebrew (STR TYPC &optional NO-REP)
"Windoz Invert Hebrew STRING (only Hebrew, neutrals and digits).
2nd param TYPC - character types in STR [== (winvert-typc STR)].
Optional NO-REP - do not replace with value from `hebrew-english-bidi-rep'."
       (let* ((ix 0)                       ;string index
              (len (length STR))           ;string length
              (istr "")                    ;inverted string
              (num "")                     ;numeric sub string
              ic rc)
           (while (< ix len)
               (setq ic (aref STR ix))
               (setq rc (aref TYPC ix))
               (cond
                   ((= rc ?D)
                           (setq num (concat num (vector ic))))
                   (t
                       (and (not NO-REP)
                            (< ic 256)     ;replace only normal chars []{}<> ...
                            (setq ic (aref hebrew-english-bidi-rep ic)))
                       (setq ic (if (and (/= ic unicode-RLM)
                                         (/= ic unicode-RLM-mule))
                                    (vector ic) ""))
                       (setq istr (concat ic num istr))
                       (setq num "")))
               (setq ix (1+ ix)))
           (concat num istr)))


(defun winvert-types (STR)
  "create a string of the types of the characters in STR.
Resolve all 'N', 'I', 'A' and 'B' to 'R', 'L', 'D' or else (neutral).
See `hebrew-english-bidi-type' for character types."
       (let ((lng (1+ (length STR)))
             (ix 0)
             typc typ-b typ-a)
           (setq STR (concat " " STR " "))
           (setq ix 0)
           (setq typ-b ? )
           (setq typc  ? )
           (while (< ix lng)
               (setq typ-a (get-bidi-type (aref STR (1+ ix))))
               (aset STR (1+ ix) typ-a)
               (if (or (= typc ?A)
                       (= typc ?B))
                   (progn
                       (if (or (= typ-b ?R)
                               (= typ-b ?L))
                           (setq typc typ-b)
                           (if (or (= typ-a ?R)
                                   (= typ-a ?L))
                               (setq typc typ-a)))
                       (if (= typc ?A)
                           (setq typc ?I)
                           (if (= typc ?B)
                               (setq typc ?N)))))
               (if (= typc ?N)
                   (if (or (= typ-b ?D)
                           (= typ-a ?D))
                       (setq typc ?D)
                       (setq typc ?I)))
               (aset STR ix typc)
               (setq typ-b typc)
               (setq typc typ-a)
               (setq ix (1+ ix)))

           ;;  convert I between Digits to Digit
           (while (string-match "DI+D" STR)
               (setq ix (1+ (match-beginning 0)))
               (while (< ix (match-end 0))
                   (aset STR ix ?D)
                   (setq ix (1+ ix))))

           ;;  convert Digits after Latin to Latin
           (while (string-match hebrew-english-bidi-num-2-latin STR)
               (setq ix (match-beginning 0))
               (while (< ix (match-end 0))
                   (aset STR ix ?L)
                   (setq ix (1+ ix))))

           (substring STR 1 -1)))


(defun winvert-encode-string (STR)
"Invert STRING (encode it for Hebrew MS Windows) of any length.
use the LTR (0xFD) for forcing break of Hebrew (R2L) substring.
Assume reading direction according to `right2left-on': nil-L2R else R2L."
       (let* ((ix  0)                          ;string index
              (S1st 0)                         ;Strong first
              (Last -1)                        ;Strong last (same type as 1st)
              (Styp ?L)                        ;Strong type (Left 2 Right !)
              (isub "")                        ;temp string
              (wstr "")                        ;winvert encoded string
              ct len typs)                     ;character type (R, L, other), string length, types string
           (setq STR (concat STR unicode-LRM-as-str unicode-RLM-as-str))
                                               ;add strong LTR+RTL terminator
           (setq typs (winvert-types STR))     ;create string of the types of STR
           (setq len (length STR))             ;string length
           (while (< ix len)
               (setq ct (aref typs ix))
               (if (or (= ct ?L)               ;ignore neutrals
                       (= ct ?R))              ;and digits
                   (if (= Styp ct)             ;same as last strong type
                       (setq Last ix)          ;yes, last strong position
                       (progn                  ;(only for documentation)
                           (if (= Styp ?L)     ;for boundary neutrals
                               (setq Last (1- ix)))
                           (setq isub (substring STR S1st (1+ Last)))
                           (setq isub (if (= Styp ?R)
                                          (winvert-string-hebrew isub (substring typs S1st (1+ Last)))
                                          (if (string-equal isub "")
                                              isub
                                               (concat
                                                   (if (= (get-bidi-type (aref isub 0)) ?L)
                                                       "" unicode-LRM-as-str)
                                                   isub
                                                   (if (= (get-bidi-type (aref isub (1- (length isub)))) ?L)
                                                       "" unicode-LRM-as-str)))))
                           (setq wstr (if right2left-on           ;Winvert R2L or L2R
                                          (concat isub wstr)      ;add on the left
                                          (concat wstr isub)))    ;add on the right
                           (setq S1st (1+ Last))   ;next Strong first
                           (setq Last ix)          ;Strong last
                           (setq Styp ct))))       ;Strong type
               (setq ix (1+ ix)))
           (if (string-equal wstr unicode-LRM-as-str)
               ""
       ;;      (setq S1st (winvert-encode-string-chk wstr 0 +1))
               (setq S1st 0)
               (setq Last (1+ (winvert-encode-string-chk wstr (1- (length wstr)) -1)))
               (substring wstr S1st Last))))


(defun winvert-encode-string-chk (STR IX NXT)
"Internal function for winvert-encode-string.
Checks if character IX of string STR is bidi-LRM.
If so and the conversion is not to right-2-left or the next (IX+NXT)
is of strong type (L or R) return (IX+NXT) else return IX."
       (setq NXT (+ IX NXT))
       (and
           (or (= (aref STR IX) unicode-LRM)
               (= (aref STR IX) unicode-LRM-mule))
           (or (not right2left-on)
               (progn
                   (setq STR (get-bidi-type (aref STR NXT)))
                   (or (= STR ?L)
                       (= STR ?R))))
           (setq IX NXT))
       IX)


(defun winvert-encode-line (&optional arg)
"Win encode line (right-2-left, left-2-right depending on `right2left-on')
so the line will be displayed as the seen visualy on Hebrew MS Windows.
if ARG given, inverse arg chars"
  (interactive "p")
       (let* ((pos (point))
              (eos (progn (if (< arg 2)
                              (end-of-line) (goto-col (1+ arg))) (point)))
              (str (buffer-substring (progn (beginning-of-line) (point)) eos)))
           (insert-string (winvert-encode-string str))
           (delete-char (length str))
           (goto-char pos)))


(defun winvert-encode-all-lines (&optional arg)
"Win encode line (right-2-left, left-2-right depending on `right2left-on')
so the line will be displayed as the seen visualy on Hebrew MS Windows.
Do it for all the lines in the buffer,
if ARG given, inverse the left (first) arg charcters in each line."
  (interactive "p")
       (goto-char (point-min))
       (let* ((eol 0)
              (bol 0)
              (str ""))
           (while (not (eobp))
               (setq bol (point))
               (end-of-line)
               (if arg
                   (goto-col arg)
                   (end-of-line))
               (setq eol (point))
               (setq str (buffer-substring bol eol))
               (delete-region bol eol)
               (insert-string (winvert-encode-string str))
               (forward-line 1))))


;;---------------------------- Justify left -------------------------------


(defun justify-in-cols (left-col right-col &optional left)
  "Justify text between LEFT-COL and RIGHT-COL (inclusive)
Justify to the right unless the optional LEFT is non nil"
       (let (beg end           ;beging/end of string (char number)
             str               ;substring (temp)
            )
           (goto-col (1+ right-col))               ;insure New line after right column
           (setq end (point))
           (goto-col left-col)                     ;1st col to justify
           (setq beg (point))
           (setq str (buffer-substring beg end))
           (delete-region beg end)
           (insert (justify-string str left))))    ;justify sub string (right/left)


(defun justify-all-lines (left-col right-col &optional left)
  "Justify text between LEFT-COL and RIGHT-COL (inclusive) on all lines
Justify to the right unless the optional LEFT is non nil"
       (let ((pos (point)))            ;saved current position (NOT marker!)
           (goto-char (point-min))
           (while (not (eobp))         ;loop until end of buffer
               (justify-in-cols left-col right-col left)   ;justify this line
               (forward-line 1))       ; goto next line
           (goto-char pos)))           ;restore position


(defun justify-string (STRING &optional left)
  "Justify STRING according to optional LEFT:
nil         - justify right (move any spaces from its end to its begining).
t (non nil) - justify left (move any spaces from its begining to its end)."
       (let ((lng (length STRING))                     ; string length
             (ix (string-match                         ; position of blanks
                     (if left "^[ ]+[^ ]" "[^ ][ ]+$") ; left / right blanks
                     STRING))
            )
           (if ix                                      ; spaces found
               (if left
                   (progn
                       (setq ix (1- (match-end 0)))
                       (setq STRING
                          (concat (substring STRING ix) (make-string ix ? ))))
                   (progn
                       (setq ix (1+ ix))
                       (setq STRING
                          (concat (make-string (- lng ix) ? ) (substring STRING 0 ix))))))
           STRING))


;;---------------------------- Hebrew sort -------------------------------


(defun right2left-sort-lines (beg end reverse)
  "Sort lines in region alphabetically from right to left, non interactive!
Must be called from a program. There are three arguments:
REVERSE (non-nil means reverse order), BEG and END (region to sort)."
       (if right2left-on
           (let ((sv-pos (point)))
               (goto-char beg)
               (beginning-of-line)
               (setq beg (point))
               (goto-char end)
               (end-of-line)
               (setq end (point))
               (save-restriction
                   (narrow-to-region beg end)
                   (invert-all-lines right2left-1st-col)
                   (sort-lines reverse (point-min) (point-max))
                   (invert-all-lines right2left-1st-col)
                   (widen))
               (goto-char sv-pos))
           (sort-lines reverse beg end)))


;;---------------------------add Hebrew chars ---------------------------------


(defun hebrew-syntax-word (&optional arg)
  "Modify the syntax of all the hebrew characters to ARG string (default is `w')."
  (interactive)
       (or arg (setq arg "w"))
       (let* ((char Alef-is))
           (while (<= char Tav-is)
               (modify-syntax-entry char arg)
               (setq char (1+ char)))))

(hebrew-syntax-word)       ;; change standard sysntax table now


;; must do for all maps !!
(defun hebeng-substitute-definitions ()
  "Subsitue key defintions in all currently defined maps:
       self-insert-command    by   self-insert-ehud
       delete-char            by   delete-char-ehud
       beginning-of-line      by   beginning-of-line-ehud
       end-of-line            by   end-of-line-ehud"
   (interactive)
       (let ((maps (apropos-internal "" 'keymap-test))
              map1)
           (while maps
               (setq map1 (car maps))
               (setq maps (cdr maps))
               (substitute-key-definition
                   'self-insert-command    'self-insert-ehud       (symbol-value map1))
               (substitute-key-definition
                   'beginning-of-line      'beginning-of-line-ehud (symbol-value map1))
               (substitute-key-definition
                   'end-of-line            'end-of-line-ehud       (symbol-value map1))
               (substitute-key-definition
                   'delete-char            'delete-char-ehud       (symbol-value map1))
               (substitute-key-definition
                   'newline-and-indent     'newline-and-indent-ehud (symbol-value map1))
               (substitute-key-definition
                   'open-line              'open-line-ehud         (symbol-value map1))
               (substitute-key-definition
                   'split-line             'split-line-ehud        (symbol-value map1))
               )))

(hebeng-substitute-definitions)        ;; execute for the 1st (only ?) time

;;;============== changes to isearch for Hebrew & PREpending =================

(defvar isearch-prepend-switch nil "non nil - prepend chars to search string")
(defvar isearch-Hebrew-switch nil  "non nil - translate typed chars to Hebrew")

(define-key isearch-mode-map "\C-b" 'isearch-yank-upto-blank)
(define-key isearch-mode-map "\C-c" 'isearch-yank-char)
(define-key isearch-mode-map "\C-h" 'isearch-toggle-Hebrew)
(define-key isearch-mode-map "\C-p" 'isearch-toggle-prepend)
(define-key isearch-mode-map "\C-t" 'isearch-toggle-case-fold)
(define-key isearch-mode-map "\C-x" 'isearch-yank-x-sel)
(define-key isearch-mode-map "\C-e" 'isearch-edit-string)

;;  (if sw-tty-on                  ;;;;;; sw-tty-on defined in MVS default.el
;;      (define-key isearch-mode-map "\C-\\" nil))             ;;clear ^\ for TTY

;;   F21 alias for `hebrew-kbd-toggle'.
;;   F22 alias for `right2left-toggle'.
;;   F23 alias for `push-mode-set'.
;;  SF21 alias for `hebrew-kbd-all'.
;;  SF22 alias for `latin-kbd-all'.
(substitute-key-definition 'F23  'isearch-toggle-both        isearch-mode-map global-map)
(substitute-key-definition 'F21  'isearch-toggle-Hebrew      isearch-mode-map global-map)
(substitute-key-definition 'F22  'isearch-toggle-prepend     isearch-mode-map global-map)
(substitute-key-definition 'SF21 'isearch-set-Hebrew-prepend isearch-mode-map global-map)
(substitute-key-definition 'SF22 'isearch-set-English-append isearch-mode-map global-map)
(substitute-key-definition 'Alt-up     'isearch-ring-retreat isearch-mode-map global-map)
(substitute-key-definition 'Alt-down   'isearch-ring-advance isearch-mode-map global-map)
(substitute-key-definition 'Alt-insert 'isearch-yank-x-sel   isearch-mode-map global-map)

(defun isearch-mode-Hebrew-addon ()
  "Added initialization for Hebrew use in isearch"
  (if push-mode-on
       (setq isearch-prepend-switch (not right2left-on)    ;negate R2L & Hebrew on push-mode
             isearch-Hebrew-switch (not hebrew-on))
       (setq isearch-prepend-switch right2left-on          ;prepend chars to search string if R2L
             isearch-Hebrew-switch hebrew-on)))            ;translate typed chars to Hebrew if Hebrew on

(add-hook 'isearch-mode-hook 'isearch-mode-Hebrew-addon)   ;add changes to isearch-mode

(defun isearch-set-Hebrew-prepend ()                           ;new function
  "Set prepending of typed char in Hebrew to search string."
  (interactive)
       (setq isearch-prepend-switch t)
       (setq isearch-Hebrew-switch t)
       (isearch-toggle-Heb-pp-msg))

(defun isearch-set-English-append ()                           ;new function
  "Set appending of typed char in English to search string."
  (interactive)
       (setq isearch-prepend-switch nil)
       (setq isearch-Hebrew-switch nil)
       (isearch-toggle-Heb-pp-msg))

(defun isearch-toggle-both ()                                  ;new function
  "Toggle prepending and language of typed char to search string."
  (interactive)
       (setq isearch-prepend-switch (not isearch-prepend-switch))
       (setq isearch-Hebrew-switch  (not isearch-Hebrew-switch))
       (isearch-toggle-Heb-pp-msg))

(defun isearch-toggle-prepend ()                               ;new function
  "Toggle prepending of typed char to search string on or off."
  (interactive)
       (setq isearch-prepend-switch (not isearch-prepend-switch))
       (isearch-toggle-Heb-pp-msg))

(defun isearch-toggle-Heb-pp-msg ()                            ;new function
  (interactive)
       (message "%s%s [%spend mode%s]"
               (isearch-message-prefix)
               isearch-message
               (if isearch-prepend-switch "pre" "ap")
               (if isearch-Hebrew-switch " Hebrew ON" ""))
       (setq isearch-adjusted t)
       (sit-for 1)
       (isearch-update))

(defun isearch-toggle-Hebrew ()                                ;new function
  "Toggle prepending of typed char to search string on or off."
  (interactive)
       (setq isearch-Hebrew-switch (not isearch-Hebrew-switch))
       (isearch-toggle-Heb-pp-msg))


;; copied from isearch.el - changed for Hebrew
(defun isearch-printing-char ()
  "Add this ordinary printing character to the search string and search."
  (interactive)
       (isearch-process-search-char
                   (if isearch-Hebrew-switch                           ;; added Hebrew translation
                       (aref hebrew-keyboard-chars last-command-char)  ;; when needed - Ehud Karni
                       last-command-char)))


;; copied from isearch.el - changed for prepend
(defun isearch-process-search-char (char)
  "Ehud Karni modified function. Sorry, no original DOC."
  ;; Append/prepend the char to the search string, update the message and re-search.
       (if isearch-prepend-switch                          ; non nil = prepend     EK
           (if isearch-forward                             ; forward ?             EK
               (if isearch-other-end                       ;                       EK
                   (setq isearch-other-end (1- isearch-other-end)))    ; yes, decrease other-end   EK
               (goto-char (1- (point)))))                  ; reverse - position to left 1 char
       (isearch-process-search-string                      ; modified function
           (char-to-string char)                           ; string to add
           (isearch-text-char-description char)))          ; message for this string

;; copied from isearch.el - changed for prepend
(defun isearch-process-search-string (string message)
  ;; Append / prepend the new-string to the search string, update the message and re-search.
       (if isearch-prepend-switch                                  ;; non nil = prepend        EK
           (setq isearch-string (concat string isearch-string)     ;;                          EK
                 isearch-message (concat message isearch-message)) ;;prepend                   EK
           (setq isearch-string (concat isearch-string string)     ;;              original
                 isearch-message (concat isearch-message message)));; append       lisp code
       (isearch-search-and-update))


(defun isearch-yank-upto-blank ()                          ;new function
  "Pull characters up to blank (all non-blank) from buffer into search string."
  (interactive)
       (isearch-yank 'blank))

(defun isearch-yank-char ()                                ;new function
  "Pull next char from buffer into search string."
  (interactive)
       (isearch-yank 'char))

(defun isearch-yank-word ()                                ;replacment function
  "Pull next word from buffer into search string."
  (interactive)
       (isearch-yank 'word))

(defun isearch-yank-line ()                                ;replacment function
  "Pull rest of line from buffer into search string."
  (interactive)
       (isearch-yank 'line))

(defun isearch-yank-x-sel ()                               ;new function
  "Pull string from X (mouse) selection into search string."
  (interactive)
       (isearch-yank 'x-sel))


;; copied from isearch.el - changed (exetensivly) for added functions
(defun isearch-yank (chunk)    ;; CHUNK should be char, word, line, kill or x-sel
  "Ehud Karni modified function. Sorry, no original DOC."
       (let* (posb                             ;buf beg pos
              string                           ;added string
              (posl (point))                   ;assume reverse / backward
              (posr (or isearch-other-end posl))
             )
           (and isearch-forward                ;forward ?
               (setq posl posr)                ;set left to other-end
               (setq posr (point)))            ;set right to current
           (if isearch-prepend-switch          ;pre pend on ?
               (progn
                   (setq posb posl)
                   (goto-char posl)            ;goto left edge
                   (cond
                       ((eq chunk 'blank)      (if (search-backward-regexp "[ \n\t]" nil t)
                                                   (forward-char 1)))
                       ((eq chunk 'char)       (backward-char 1))
                       ((eq chunk 'word)       (backward-word 1))
                       ((eq chunk 'line)       (beginning-of-line)))
                   (setq posl (point)))        ; NEW left position !
               (progn
                   (setq posb posr)
                   (goto-char posr)            ;goto right edge
                   (cond
                       ((eq chunk 'blank)      ;
                               (if (search-forward-regexp "[ \n\t]" nil t)
                                   (backward-char 1)))
                       ((eq chunk 'char)       (forward-char 1))
                       ((eq chunk 'word)       (forward-word 1))
                       ((eq chunk 'line)       (end-of-line)))))
           (setq string (cond
                   ((eq chunk 'kill)   (current-kill 0))                       ;; killed chunk
                   ((eq chunk 'x-sel)  (x-get-selection 'PRIMARY 'STRING))     ;; clipboard (mouse)
                   (t                  (buffer-substring (point) posb))))      ;; buffer chunk
           ;; original lisp code (re formatted)
           (if (and isearch-case-fold-search               ;; Downcase the string if not supposed
                    (eq 'not-yanks search-upper-case))     ;; to case-fold yanked strings.
               (setq string (downcase string)))
           (if isearch-regexp
               (setq string (regexp-quote string)))
           (if isearch-forward                         ; forward ?
               (setq isearch-other-end posl)           ; yes, set other-end
               (goto-char posl))                       ; reverse - position to left edge
           (setq isearch-yank-flag t)                  ; Don't check barier in reverse search.
           (isearch-process-search-string string
                                   (mapconcat 'isearch-text-char-description string ""))))

;; ################# end of hebeng.el (EK) ==================================
