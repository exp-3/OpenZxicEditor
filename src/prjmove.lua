-- prjmove.lua
-- ΪOpenZxicEditor-For-Windows�ṩĿ¼����������
-- 
-- ��Ȩ���� (C) 2024-2025 MiFi~Lab & OpenZxicEditor Developers. 
-- ��Ȩ���� (C) 2024-2025 ����Punguin. 
--
--
-- ����������������������Ի��������������ᷢ����GNU Afferoͨ�ù������֤�����������·ַ���/���޸��������߱����֤��������ߣ�����ѡ���κκ����汾��
-- �ַ���������ϣ�����������ó�����û���κε���������Ҳû�ж��������Ի��ض�Ŀ�������Ե�Ĭʾ����������ϸ����μ���GNU Afferoͨ�ù������֤����
-- ��Ӧ�����յ��������渽��GNU Afferoͨ�ù������֤�ĸ�������δ�յ�����μ���http://www.gnu.org/licenses/ ��
--


-- ��ȡ MTDs/name.txt
local f = io.open("MTDs/name.txt", "r")
local name = f:read("*all")
f:close()
-- �� "MTDs" Ŀ¼������Ϊ "z.�̼���"�������ո��滻�ɵ�
os.rename("MTDs", "z." .. name:gsub(" ", "."))