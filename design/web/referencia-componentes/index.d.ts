import type * as React from 'react';

export type AppointmentStatus = 'Pendiente' | 'Confirmada' | 'EnProgreso' | 'Completada' | 'Cancelada' | 'NoShow';
export type ServiceType = 'Corte' | 'Afeitado' | 'Barba' | 'Tinte' | 'Tratamiento' | 'Combo' | 'Otro';
export type Tone = 'neutral' | 'brass' | 'success' | 'warning' | 'danger' | 'info' | 'oxblood';

export interface LogoProps { variant?: 'horizontal' | 'emblem'; height?: number; surface?: 'auto' | 'light' | 'dark'; className?: string }
export declare function Logo(props: LogoProps): React.ReactElement;

export interface IconProps { name: string; size?: 16 | 20 | 24 | number; label?: string; strokeWidth?: number; className?: string }
export declare function Icon(props: IconProps): React.ReactElement;

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger' | 'danger-ghost';
  size?: 'sm' | 'md' | 'lg';
  icon?: string; iconRight?: string; loading?: boolean; block?: boolean;
}
export declare function Button(props: ButtonProps): React.ReactElement;

export interface IconButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> { icon: string; label: string; variant?: 'ghost' | 'secondary'; size?: 'sm'; badge?: boolean }
export declare function IconButton(props: IconButtonProps): React.ReactElement;

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> { label?: string; hint?: string; error?: string; icon?: string; trailing?: React.ReactNode; optional?: boolean; multiline?: boolean; revealable?: boolean }
export declare function Input(props: InputProps): React.ReactElement;

export interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> { label?: string; hint?: string; error?: string; optional?: boolean; placeholder?: string; options: Array<string | { value: string; label: string }> }
export declare function Select(props: SelectProps): React.ReactElement;

export interface SwitchProps { label: string; hint?: string; checked?: boolean; defaultChecked?: boolean; onChange?: (checked: boolean) => void; disabled?: boolean; id?: string }
export declare function Switch(props: SwitchProps): React.ReactElement;

export interface ChipProps extends React.ButtonHTMLAttributes<HTMLButtonElement> { selected?: boolean; icon?: string; count?: number; onRemove?: () => void; as?: 'tag' }
export declare function Chip(props: ChipProps): React.ReactElement;

export interface StatusBadgeProps { status: AppointmentStatus; size?: 'sm'; className?: string }
export declare function StatusBadge(props: StatusBadgeProps): React.ReactElement;

export interface BadgeProps { tone?: Tone; icon?: string; children?: React.ReactNode; className?: string }
export declare function Badge(props: BadgeProps): React.ReactElement;

export interface RatingProps { value: number; count?: number; compact?: boolean; size?: number }
export declare function Rating(props: RatingProps): React.ReactElement;

export interface AvatarProps { name?: string; src?: string; size?: 24 | 32 | 40 | 48 | 64 | number; status?: 'on' | 'off' }
export declare function Avatar(props: AvatarProps): React.ReactElement;

export interface ServiceCardProps { name: string; type?: ServiceType; description?: string; duration: number; price: number | string; image?: string; tag?: string; selected?: boolean; onClick?: () => void }
export declare function ServiceCard(props: ServiceCardProps): React.ReactElement;

export interface BarberCardProps { name: string; photo?: string; rating?: number; reviews?: number; years: number; specialties?: string[]; available?: boolean; unavailableLabel?: string; selected?: boolean; onClick?: () => void; onProfile?: () => void }
export declare function BarberCard(props: BarberCardProps): React.ReactElement;

export interface AppointmentCardProps { service: string; barber: string; barberPhoto?: string; date: string | Date; start: string; end: string; status: AppointmentStatus; price?: number; actions?: React.ReactNode | Array<{ label: string; variant?: ButtonProps['variant']; icon?: string; size?: ButtonProps['size']; href?: string; onClick?: () => void }> }
export declare function AppointmentCard(props: AppointmentCardProps): React.ReactElement;

export interface StatCardProps { label: string; value: string; icon?: string; delta?: number; deltaLabel?: string; invert?: boolean; hint?: string }
export declare function StatCard(props: StatCardProps): React.ReactElement;

export interface StepperProps { current: 1 | 2 | 3 | 4 | number; steps?: string[] }
export declare function Stepper(props: StepperProps): React.ReactElement;

export interface CalendarProps { year: number; month: number; today?: number; selected?: number; disabled?: (day: number) => boolean; marks?: Record<number, 'few' | 'any'>; legend?: string }
export declare function Calendar(props: CalendarProps): React.ReactElement;

export interface Slot { time: string; state?: 'available' | 'booked' | 'blocked' | 'hold'; note?: string }
export interface SlotGridProps { slots: Slot[]; selected?: string; mode?: 'client' | 'admin'; label?: string }
export declare function SlotGrid(props: SlotGridProps): React.ReactElement;

export interface CountdownProps { seconds: number; total?: number; variant?: 'compact'; label?: string }
export declare function Countdown(props: CountdownProps): React.ReactElement;

export interface TabItem { value: string; label: string; icon?: string; count?: number }
export interface TabsProps { items: Array<string | TabItem>; value: string; onChange?: (value: string) => void; variant?: 'underline' | 'segmented'; label?: string }
export declare function Tabs(props: TabsProps): React.ReactElement;

export interface TableColumn<R = any> { key: string; label: React.ReactNode; align?: 'right'; muted?: boolean; sort?: 'asc' | 'desc'; render?: (row: R) => React.ReactNode }
export interface TableProps<R = any> { columns: TableColumn<R>[]; rows: R[]; caption?: string }
export declare function Table(props: TableProps): React.ReactElement;

export interface PaginationProps { page?: number; pages?: number; total: number; perPage?: number; variant?: 'pages' | 'more'; shown?: number; loading?: boolean }
export declare function Pagination(props: PaginationProps): React.ReactElement;

export interface ModalProps { title: string; subtitle?: string; children?: React.ReactNode; footer?: React.ReactNode | Array<{ label: string; variant?: ButtonProps['variant']; icon?: string; href?: string; onClick?: () => void }>; size?: 'md' | 'lg'; sheet?: boolean; inline?: boolean }
export declare function Modal(props: ModalProps): React.ReactElement;

export interface ConfirmDialogProps { title: string; body: string; confirmLabel: string; cancelLabel?: string; tone?: 'danger' | 'info'; icon?: string; inline?: boolean }
export declare function ConfirmDialog(props: ConfirmDialogProps): React.ReactElement;

export interface ToastProps { tone?: 'success' | 'danger' | 'info' | 'warning'; children: React.ReactNode; action?: string; dismissible?: boolean; icon?: string }
export declare function Toast(props: ToastProps): React.ReactElement;

export interface BannerProps { tone?: 'info' | 'success' | 'warning' | 'danger' | 'brass'; title?: string; children?: React.ReactNode; action?: string; icon?: string }
export declare function Banner(props: BannerProps): React.ReactElement;

export interface SkeletonProps { variant?: 'text' | 'card' | 'slots' | 'row'; label?: string }
export declare function Skeleton(props: SkeletonProps): React.ReactElement;

export interface EmptyStateProps { icon?: string; title: string; body?: string; action?: React.ReactNode; actionLabel?: string; actionIcon?: string; actionVariant?: ButtonProps['variant']; onAction?: () => void; tone?: 'error' }
export declare function EmptyState(props: EmptyStateProps): React.ReactElement;

export interface NavItem { icon: string; label: string; count?: number; badge?: boolean }
export interface SidebarProps { sections: Array<{ title: string; items: NavItem[] }>; active?: string; user?: { name: string; role: string } }
export declare function Sidebar(props: SidebarProps): React.ReactElement;

export interface TopbarProps { title?: string; placeholder?: string; theme?: 'light' | 'dark'; unread?: boolean; compact?: boolean }
export declare function Topbar(props: TopbarProps): React.ReactElement;

export interface BottomNavProps { items?: NavItem[]; active?: string; floating?: boolean }
export declare function BottomNav(props: BottomNavProps): React.ReactElement;

export interface AgendaItem { client?: string; service?: string; start: string; end: string; status?: AppointmentStatus; block?: boolean; href?: string; selected?: boolean }
export interface AgendaBoardProps { barbers: Array<{ name: string; photo?: string; count?: number; sub?: string; avatar?: boolean; current?: boolean; items: AgendaItem[] }>; start?: string; end?: string; now?: string; pxPerMin?: number }
export declare function AgendaBoard(props: AgendaBoardProps): React.ReactElement;

export declare const format: { cop(n: number): string; time(t: string | number, compact?: boolean): string; duration(min: number): string; initials(name: string): string };

declare global {
  interface Window {
    BSM: {
      Logo: typeof Logo; Icon: typeof Icon; Button: typeof Button; IconButton: typeof IconButton; Input: typeof Input; Select: typeof Select;
      Switch: typeof Switch; Chip: typeof Chip; StatusBadge: typeof StatusBadge; Badge: typeof Badge; Rating: typeof Rating; Avatar: typeof Avatar;
      ServiceCard: typeof ServiceCard; BarberCard: typeof BarberCard; AppointmentCard: typeof AppointmentCard; StatCard: typeof StatCard;
      Stepper: typeof Stepper; Calendar: typeof Calendar; SlotGrid: typeof SlotGrid; Countdown: typeof Countdown; Tabs: typeof Tabs;
      Table: typeof Table; Pagination: typeof Pagination; Modal: typeof Modal; ConfirmDialog: typeof ConfirmDialog; Toast: typeof Toast;
      Banner: typeof Banner; Skeleton: typeof Skeleton; EmptyState: typeof EmptyState; Sidebar: typeof Sidebar; Topbar: typeof Topbar;
      BottomNav: typeof BottomNav; AgendaBoard: typeof AgendaBoard; format: typeof format;
    };
  }
}
