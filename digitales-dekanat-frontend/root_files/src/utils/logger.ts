/**
 * Logging Utility for DigiDekan Frontend
 *
 * Provides centralized logging with:
 * - Environment-based log level control
 * - Structured log formatting
 * - Production-safe logging (disabled in production)
 * - Type-safe logging methods
 */

export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  NONE = 4,
}

interface LoggerConfig {
  minLevel: LogLevel;
  enableInProduction: boolean;
  enableTimestamp: boolean;
  enableCaller: boolean;
}

class Logger {
  private config: LoggerConfig;
  private isProduction: boolean;

  constructor(config?: Partial<LoggerConfig>) {
    this.isProduction = import.meta.env.PROD || import.meta.env.MODE === 'production';

    this.config = {
      minLevel: this.isProduction ? LogLevel.WARN : LogLevel.DEBUG,
      enableInProduction: false,
      enableTimestamp: !this.isProduction,
      enableCaller: !this.isProduction,
      ...config,
    };
  }

  /**
   * Check if logging is allowed based on environment and level
   */
  private shouldLog(level: LogLevel): boolean {
    if (this.isProduction && !this.config.enableInProduction) {
      // In production, only allow ERROR and WARN by default
      return level >= LogLevel.WARN;
    }
    return level >= this.config.minLevel;
  }

  /**
   * Format log message with metadata
   */
  private formatMessage(level: LogLevel, context: string, message: string): string {
    const parts: string[] = [];

    if (this.config.enableTimestamp) {
      parts.push(`[${new Date().toISOString()}]`);
    }

    parts.push(`[${LogLevel[level]}]`);

    if (context) {
      parts.push(`[${context}]`);
    }

    parts.push(message);

    return parts.join(' ');
  }

  /**
   * Internal logging method
   */
  private log(
    level: LogLevel,
    context: string,
    message: string,
    ...args: any[]
  ): void {
    if (!this.shouldLog(level)) {
      return;
    }

    const formattedMessage = this.formatMessage(level, context, message);

    switch (level) {
      case LogLevel.DEBUG:
        console.log(formattedMessage, ...args);
        break;
      case LogLevel.INFO:
        console.info(formattedMessage, ...args);
        break;
      case LogLevel.WARN:
        console.warn(formattedMessage, ...args);
        break;
      case LogLevel.ERROR:
        console.error(formattedMessage, ...args);
        break;
    }
  }

  /**
   * Debug level logging - disabled in production
   */
  public debug(context: string, message: string, ...args: any[]): void {
    this.log(LogLevel.DEBUG, context, message, ...args);
  }

  /**
   * Info level logging - disabled in production
   */
  public info(context: string, message: string, ...args: any[]): void {
    this.log(LogLevel.INFO, context, message, ...args);
  }

  /**
   * Warning level logging - enabled in production
   */
  public warn(context: string, message: string, ...args: any[]): void {
    this.log(LogLevel.WARN, context, message, ...args);
  }

  /**
   * Error level logging - always enabled
   */
  public error(context: string, message: string, error?: Error | any, ...args: any[]): void {
    if (error instanceof Error) {
      this.log(LogLevel.ERROR, context, message, error.message, error.stack, ...args);
    } else {
      this.log(LogLevel.ERROR, context, message, error, ...args);
    }
  }

  /**
   * Set minimum log level
   */
  public setLevel(level: LogLevel): void {
    this.config.minLevel = level;
  }

  /**
   * Enable/disable production logging
   */
  public setProductionLogging(enabled: boolean): void {
    this.config.enableInProduction = enabled;
  }
}

// Export singleton instance
export const logger = new Logger();

// Export for testing and advanced usage
export { Logger };

// Convenience exports for common contexts
export const createContextLogger = (context: string) => ({
  debug: (message: string, ...args: any[]) => logger.debug(context, message, ...args),
  info: (message: string, ...args: any[]) => logger.info(context, message, ...args),
  warn: (message: string, ...args: any[]) => logger.warn(context, message, ...args),
  error: (message: string, error?: Error | any, ...args: any[]) =>
    logger.error(context, message, error, ...args),
});
